const checkTaskC = async () =>  {
    const c = await getAssContract(deployer);

    let tx = await c.forceReset();
    await tx.wait();

    tx = await c.setMaxTime('start', 1);
    await tx.wait();

    tx = await c.setBlockNumber(1000);
    await tx.wait();

    tx = await c.start({ 
        value: ethers.utils.parseEther("0.001")
    });
    await tx.wait();

    tx = await c.setBlockNumber(1005);
    await tx.wait();

    let res = await c.callStatic.start({value: ethers.utils.parseEther("0.001")})
    console.log(Number(res));
};