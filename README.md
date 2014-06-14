# BenchCompression

## SYNOPSIS
Bench various methods of compression on various files/directories to find the most effective method for your computer.

![Example of graph output](http://lutim.cpy.re/KH5291wy, "Example of graph output")

## USAGE

### Simple usage

    cp configuration.example.yaml configuration.yaml
    $EDITOR configuration.yaml
    chmod +x benchCompression
    mkdir graphs
    ./benchCompression

This commands will produce graphes for each input (by efficiency, size after, size reduced and execution time).

### Advanced usage
BenchCompression is a module so you can use it in your scripts. The bin "benchCompression" is just an example :)

## Configuration

You have an example of the typical configuration in the configuration.example.yaml file.

* **outdir** : Directory to put the compressed files/directories. Have to be empty otherwise can cause bugs
* **to_test** : Directorees or files to test. 

**Warning !** Directories do not have to contain the final "/"
* **compressions** 
    * **[method's name]** The name of the method of compression (zip, 7z...)
        * **out** Extension of the method of compression without the . (zip, tar.gz...)
        * **command** The command to execute the method of compression. 

        :infile: represents the filepath to compress

        :outfile: represents the filepath compressed
