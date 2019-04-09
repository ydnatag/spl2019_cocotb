# COCOTB: Test en Python

Este repositorio posee los fuentes necesarios para realizar el
workshop "Testbench en Python" del SPL2019.

# Ejercicios y ejemplos

Para ejecutar cualquier ejemplo o práctica se deben setear
primeramente las variables de entorno:

```bash
source utils/env.sh
```

Posteriormente, moverse hasta la carpeta del ejemplo/practica
y ejecutar:

```bash
cd <PATH_AL_EJEMPLO>
make
```

Para ver las waveforms generadas para el caso de simulaciones
de HDL:

```bash
make gtkwave
```

# Requerimientos

* Docker
* git

# Links de interés

* [Link a la presentación](https://andresdemski.github.io/spl2019_cocotb)
* [Repositorio de COCOTB](https://github.com/potentialventures/cocotb)
* [Doc de COCOTB](https://cocotb.readthedocs.io)

