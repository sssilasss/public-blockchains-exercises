// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BaseAssignment.sol";

contract Assignment2 is BaseAssignment{

    constructor() 
        BaseAssignment(0xbb94CBc84004548b9e174955bB4e26a1757cc5C3)

{}



    //Status public state = Status.waiting;
    string public choiceplayer1;
    string public choiceplayer2;
    bytes32 public choiceplayer1_hashed;
    bytes32 public choiceplayer2_hashed;
    string public plainChoicePlayer1;
    string public plainChoicePlayer2;
    uint public playerId;
    uint256 public gameCounter = 0;
    address public player1;
    address public player2;
    string state = "waiting";
    uint public fee = 0.001 ether;
    mapping (address => uint) public balance;


    uint private  starttime = 10;
    uint private  playtime = 10;
    uint private revealtime = 10;

    uint private blockNumberStart;
    uint private blockNumberPlay;
    uint private blockNumberReveal;
   


    //events
    event Started(uint _gameCounter, address _player1);
    event Playing(uint _gameCounter, address _player1, address _player2);
    event Ended(uint _gameCounter, address _winner, int _outcome);

    function getState() public view returns (string memory) {
        return state;
    }

    function getGameCounter() public view returns (uint256) {
        return gameCounter;
    }


    function start() public payable returns(uint256) {
        
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("waiting")) || keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("starting")));
        checkMaxTime();
        require(msg.value == fee,"Not enough ether");
        //require(msg.sender != player1 || msg.sender != player2);
        if (player1 == address(0)) {
            player1 = msg.sender;
            state = "starting";
            gameCounter += 1;
            playerId = 1;
            blockNumberStart = getBlockNumber();
            emit Started(gameCounter,player1);
        }
        else {
            player2 = msg.sender;
            state = "playing";
             playerId = 2;
            emit Playing(gameCounter,player1,player2);
        }
        balance[address(this)] += fee;
        return playerId;
    }

    function play(string memory choice) public {
        checkMaxTime();
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("playing")));
        require(msg.sender == player1 || msg.sender == player2);
        require(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("rock")) || keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("paper")) || keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("scissors")));
        
        blockNumberPlay = getBlockNumber();
        
        if (msg.sender == player1) {
            require(keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("")));
            choiceplayer1 = choice;
        }
        else if (msg.sender == player2) {
            require(keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked("")));
            choiceplayer2 = choice;
        }
        int outcome;
        address winner;
        // play logic
        // just one submitted
        if (keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("")) || keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked(""))){
            outcome = -1;
        }
        //player 1 wins
        else if (keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("rock")) && keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked("scissors"))){
            outcome = 1;
            winner = player1;
        } 
        else if (keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("scissors")) && keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked("paper"))){
            outcome = 1;
            winner = player1;
        }
        else if (keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("paper")) && keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked("rock"))){
            outcome = 1;
            winner = player1;
        }
        //player 2 wins
        else if (keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("scissors")) && keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked("rock"))){
            outcome = 2;
            winner = player2;
        }
        else if (keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("paper")) && keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked("scissors"))){
            outcome = 2;
            winner = player2;
        }
        else if (keccak256(abi.encodePacked(choiceplayer1)) == keccak256(abi.encodePacked("rock")) && keccak256(abi.encodePacked(choiceplayer2)) == keccak256(abi.encodePacked("paper"))){
            outcome = 2;
            winner = player2;
        }
        // tie
        else {
            outcome = 0;
        }
        // send ether to winner
        if (outcome == 1) {
            (bool sent, ) = player1.call{value: balance[address(this)]}("");
            require(sent, "Failed to send Ether");
            balance[address(this)] = 0;
        } 
        else if (outcome == 2) {
            (bool sent, ) = player2.call{value: balance[address(this)]}("");
            require(sent, "Failed to send Ether");
            balance[address(this)] = 0;
        }

        // unregister
        if (outcome == 0 || outcome == 1 || outcome == 2) {
        emit Ended(gameCounter,winner,outcome);
        state = "waiting";
        delete player1;
        delete player2;
        delete choiceplayer1;
        delete choiceplayer2;
        
        }

        //return outcome;
    }


    // Set max time 
    function setMaxTime (string memory action, uint256 maxTime) public {
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("waiting")));
        require(keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("start")) || keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("play")) || keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("reveal")));
        if (keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("start"))) {
            //if (maxTime == 0) {
                starttime = maxTime;
                //blockNumberStart = BaseAssignment.getBlockNumber() + starttime;
            //    starttime =  BaseAssignment.getBlockNumber() + 10;
            //}
            //else {
               // starttime = BaseAssignment.getBlockNumber() + maxTime;
            //}
        }
        else if (keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("play"))){
            //if (maxTime == 0) {
            //   playtime = BaseAssignment.getBlockNumber() + 10;
            //}
            //else {
                playtime = maxTime;
                //blockNumberPlay = BaseAssignment.getBlockNumber() + playtime;
            //}
        }
        else if (keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("reveal"))) {
                revealtime = maxTime;
        }
        

    }

    // Check max time
    function checkMaxTime () public returns (bool) {
        uint blocknumber = BaseAssignment.getBlockNumber();
        if (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("starting")) && blocknumber > blockNumberStart + starttime) {
            emit Ended(gameCounter,player1,-1);
            state = "waiting";

            (bool sent, ) = player1.call{value: fee}("");
            require(sent, "Failed to send Ether");
            balance[address(this)] -= fee;
            player1 = address(0);
            player2 = address(0);
            delete choiceplayer1;
            return true;
        }
        else if (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("playing")) && blocknumber > blockNumberPlay + playtime) {
            state ="waiting";
            if (keccak256(abi.encodePacked(choiceplayer1)) != keccak256(abi.encodePacked(''))) {
                emit Ended(gameCounter, player1,-1);
                (bool sent, ) = player1.call{value: 2*fee}("");
                require(sent, "Failed to send Ether");
                balance[address(this)] -= 2*fee;
            }
            else if (keccak256(abi.encodePacked(choiceplayer2)) != keccak256(abi.encodePacked(''))) {
                emit Ended(gameCounter,player2,-1);
                (bool sent, ) = player2.call{value: 2*fee}("");
                require(sent, "Failed to send Ether");
                balance[address(this)] -= 2*fee;

            }

            delete player1;
            delete player2;
            delete choiceplayer1;
            delete choiceplayer2;
            return true;
        }
        else if (keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("revealing")) && blocknumber > blockNumberReveal + revealtime) {
            if (keccak256(abi.encodePacked(plainChoicePlayer1)) != keccak256(abi.encodePacked(''))) {
                (bool sent, ) = player1.call{value: 2*fee}("");
                require(sent, "Failed to send Ether");
                balance[address(this)] -= fee;
            }
            else if (keccak256(abi.encodePacked(plainChoicePlayer2)) != keccak256(abi.encodePacked(''))) {
                (bool sent, ) = player2.call{value: 2*fee}("");
                require(sent, "Failed to send Ether");
                balance[address(this)] -= fee;
            }
            state = "waiting";
            delete player1;
            delete player2;
            delete choiceplayer1_hashed;
            delete choiceplayer2_hashed;
            return true;
        }
        else {
            return false;
        }
    }


    function forceReset() public{
        require(isValidator(msg.sender));
         state = "waiting";
        delete player1;
        delete player2;
        delete choiceplayer1;
        delete choiceplayer2;

    }




       // Play private
    function playPrivate (bytes32 hashedChoice) public {
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("playing")));
        require(msg.sender == player1 || msg.sender == player2);
        if (msg.sender == player1) {
            require(keccak256(abi.encodePacked(choiceplayer1_hashed)) == keccak256(abi.encodePacked("")));
            choiceplayer1_hashed = hashedChoice;
        }
        else if (msg.sender == player2) {
            require(keccak256(abi.encodePacked(choiceplayer2_hashed)) == keccak256(abi.encodePacked("")));
            choiceplayer2_hashed = hashedChoice;
        }
        if (keccak256(abi.encodePacked(choiceplayer1_hashed)) != keccak256(abi.encodePacked("")) && keccak256(abi.encodePacked(choiceplayer2_hashed)) != keccak256(abi.encodePacked(""))) {
            state = "revealing";
            blockNumberReveal = BaseAssignment.getBlockNumber();
        }
        
    }

    // Reveal private play
    function reveal (string memory plainChoice, string memory seed) public{
        require(keccak256(abi.encodePacked(state)) == keccak256(abi.encodePacked("revealing")));
        require(msg.sender == player1 || msg.sender == player2);
        string memory test = string.concat(seed, "_", plainChoice);
        if (msg.sender == player1 && keccak256(abi.encodePacked(test)) == choiceplayer1_hashed) {
            plainChoicePlayer1 = plainChoice;
        }
        else if (msg.sender == player2 && keccak256(abi.encodePacked(test)) == choiceplayer2_hashed) {
            plainChoicePlayer2 = plainChoice;
        }

        int outcome;
        address winner;
        // play logic
        //player 1 wins
        if (keccak256(abi.encodePacked(plainChoicePlayer1)) == keccak256(abi.encodePacked('rock')) && keccak256(abi.encodePacked(plainChoicePlayer2)) == keccak256(abi.encodePacked('scissors'))){
            outcome = 1;
            winner = player1;
        } 
        else if (keccak256(abi.encodePacked(plainChoicePlayer1)) == keccak256(abi.encodePacked('scissors')) && keccak256(abi.encodePacked(plainChoicePlayer2)) == keccak256(abi.encodePacked('paper'))) {
            outcome = 1;
            winner = player1;
        }
        else if (keccak256(abi.encodePacked(plainChoicePlayer1)) == keccak256(abi.encodePacked('paper')) && keccak256(abi.encodePacked(plainChoicePlayer2)) == keccak256(abi.encodePacked('rock'))){
            outcome = 1;
            winner = player1;
        }
        //player 2 wins
        else if (keccak256(abi.encodePacked(plainChoicePlayer1)) == keccak256(abi.encodePacked('scissors')) && keccak256(abi.encodePacked(plainChoicePlayer2)) == keccak256(abi.encodePacked('rock'))){
            outcome = 2;
            winner = player2;
        }
        else if (keccak256(abi.encodePacked(plainChoicePlayer1)) == keccak256(abi.encodePacked('paper')) && keccak256(abi.encodePacked(plainChoicePlayer2)) == keccak256(abi.encodePacked('scissors'))){
            outcome = 2;
            winner = player2;
        }
        else if (keccak256(abi.encodePacked(plainChoicePlayer1)) == keccak256(abi.encodePacked('rock')) && keccak256(abi.encodePacked(plainChoicePlayer2)) == keccak256(abi.encodePacked('paper'))){
            outcome = 2;
            winner = player2;
        }
        // tie
        else {
            outcome = 0;
        }
        // send ether to winner
        if (outcome == 1) {
            (bool sent, ) = player1.call{value: balance[address(this)]}("");
            require(sent, "Failed to send Ether");
            balance[address(this)] = 0;
        } 
        else if (outcome == 2) {
            (bool sent, ) = player2.call{value: balance[address(this)]}("");
            require(sent, "Failed to send Ether");
            balance[address(this)] = 0;
        }

        // unregister
        if (outcome == 0 || outcome == 1 || outcome == 2) {
        emit Ended(gameCounter,winner,outcome);
        state = "waiting";
        delete player1;
        delete player2;
        delete plainChoicePlayer1;
        delete plainChoicePlayer2;

        }
    }


}