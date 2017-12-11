"Cat-400" (c4) is a game framework for Nim programming language. Being a framework means that c4 will do all the dirty job for you while you focus on creating your game. Under active development.

### Ensure you can launch it
First, install latest c4:

    nimble install https://github.com/c0ntribut0r/cat-400@#head

Create test project:

    mkdir /tmp/testapp
    cd /tmp/testapp
    touch testapp.nim
    
Now edit `testapp.nim`:

    from c4.main import run
    from c4.config import Config


    const conf: Config = (version: "0.1")

    when isMainModule:  
        run(conf)


Check whether you can launch c4 and show version:

    nim c -r testapp.nim -v
