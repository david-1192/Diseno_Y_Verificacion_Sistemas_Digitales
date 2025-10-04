# Proyecto UART-PWM en Verilog

Este proyecto implementa un sistema digital en Verilog que integra:

- **UART RX**: Recepción de datos seriales.
- **Buffer de almacenamiento**: Guarda los datos recibidos.
- **Parser de comandos**: Interpreta instrucciones.
- **Controlador PWM**: Genera señal modulada en ancho de pulso.
- **UART TX**: Transmite información de vuelta.

El flujo completo es:

```
UART RX → RX Buffer → Command Parser → PWM Controller → UART TX
```

El desarrollo se realizó de forma iterativa, usando **Icarus Verilog (iverilog)**, **GTKWave** y asistencia de IA para depuración y sugerencias en la documentación.

---

## Estructura del Proyecto

```
uart_pwm_project/
├── rtl/         # Módulos Verilog
│   ├── uart_rx.v
│   ├── uart_tx.v
│   ├── rx_buffer.v
│   ├── cmd_parser.v
│   ├── pwm.v
│   ├── freq_scale.v
│   ├── pwm_ctrl.v
│   └── top.v
├── tb/          # Testbenches
│   ├── tb_uart_rx.v
│   ├── tb_uart_tx.v
│   ├── tb_rx_buffer.v
│   ├── tb_pwm.v
│   └── tb_top.v
├── sim/         # Simulación y Makefile
│   ├── Makefile
│   └── build/
└── README.md    # Documentación
```

---

## Ejecución de Simulaciones

1. Abre una terminal en la carpeta `sim`.
2. Ejecuta la simulación deseada:

   ```bash
   make sim SIM=tb_top
   ```

   Para módulos individuales:

   ```bash
   make sim SIM=tb_uart_rx
   make sim SIM=tb_pwm
   ```

3. Visualiza las ondas con:

   ```bash
   gtkwave wave_top.vcd
   ```

---

## Descripción de Módulos

| Módulo         | Función Principal                                      |
|----------------|--------------------------------------------------------|
| UART RX        | Recibe datos seriales y entrega bytes válidos          |
| RX Buffer      | Almacena datos y detecta fin de línea                  |
| Command Parser | Interpreta comandos: Dnn (duty), Fnn (frecuencia), E0/1|
| PWM Controller | Genera señal PWM según configuración                   |
| UART TX        | Envía mensajes de confirmación o datos                 |

---

## Comandos UART Soportados

| Comando | Descripción                       | Ejemplo |
|---------|-----------------------------------|---------|
| Dnn     | Configura ciclo útil PWM (%)      | D50     |
| Fnn     | Configura divisor de frecuencia   | F03     |
| E0/E1   | Deshabilita/Habilita PWM          | E1      |

---

## Preguntas y Respuestas Clave

1. **¿Cómo debo estructurar un proyecto en Verilog que combine UART, buffer, parser y PWM en un solo flujo?**  
   Se recomienda dividirlo en módulos pequeños y específicos (UART RX, RX Buffer, Command Parser, PWM, UART TX) y luego integrar todo en un `top.v`. Esto permite una mejor verificación por partes y facilita la depuración.

2. **¿Cuál es la forma correcta de simular un módulo UART_RX en Icarus Verilog?**  
   Se debe preparar un testbench que genere un reloj, un reset, y una señal rx con la secuencia de bits seriales que representen caracteres. Luego, se compila con iverilog y se ejecuta con vvp, produciendo un .vcd para visualizar en GTKWave.

3. **¿Por qué, si simulo varios testbenches, parece que siempre se abre el de uart_rx?**  
   Es porque el Makefile estaba configurado para generar un único archivo de salida (sim.out) y el último .vcd sobrescribía a los demás. La solución fue configurar cada simulación con nombres de .vcd independientes.

4. **¿Qué pasos debo seguir para crear un testbench básico para rx_buffer?**  
   El testbench debe generar una secuencia de escritura (wr_en con datos) y posteriormente habilitar lectura (rd_en) para verificar que los datos se almacenan y se recuperan correctamente, además de probar condiciones de full y empty.

5. **¿Cómo pruebo el módulo pwm_ctrl de manera aislada?**  
   Se deben generar valores de duty_cfg y de divisores de frecuencia (pow2_cfg, pow5_cfg) desde un testbench, con cfg_valid habilitado. Luego se observa en el .vcd si la salida pwm_out refleja el duty cycle configurado.

6. **¿Qué debo esperar ver en GTKWave al simular el PWM?**  
   La señal pwm_out debe oscilar entre alto y bajo con un ciclo de trabajo proporcional al valor configurado, y su frecuencia debe variar según el divisor aplicado en freq_scale.

7. **¿Por qué en mi simulación pwm_out siempre se queda en bajo?**  
   Esto ocurre porque el cmd_parser nunca estaba activando la señal enable_pwm. La solución fue asegurarse de que los comandos UART incluyan el caracter "E" seguido de un valor 1 para habilitarlo.

8. **¿Cómo puedo asegurarme de que el parser recibe correctamente los comandos UART?**  
   Se debe simular el envío de cadenas completas como "D50", "F03", "E1" usando el UART RX en el testbench del top. Así, cada comando llega como bytes separados y el parser los procesa en su FSM.

9. **¿Qué debo modificar en cmd_parser.v para que reconozca letras como D, F y E?**  
   Se deben comparar los valores ASCII de los caracteres recibidos con las letras deseadas, y según cuál se detecte, asignar el siguiente dato al registro correspondiente (duty, frecuencia, enable).

10. **¿Cómo debe comportarse la FSM del parser de comandos?**  
    En estado IDLE espera un comando válido, en estado CMD guarda la instrucción, en estado DATA captura el valor asociado y actualiza las salidas, luego vuelve a IDLE.

11. **¿Es necesario recompilar todos los módulos si solo cambio el testbench?**  
    Sí, porque Icarus Verilog recompila cada vez los archivos fuente. Sin embargo, si no modificas los módulos, basta con asegurarte que el Makefile incluya los mismos archivos RTL.

12. **¿Cómo puedo enviar datos desde el testbench al UART RX del top?**  
    Se debe implementar una tarea en el testbench que genere la secuencia serial de bits (start, 8 bits de dato, stop) sincronizada con el baudrate, para que el uart_rx los decodifique.

13. **¿Qué pasa si no genero un archivo .vcd en el testbench?**  
    La simulación corre pero no se puede visualizar en GTKWave. Es obligatorio incluir `$dumpfile` y `$dumpvars` en cada testbench para poder analizar las ondas.

14. **¿Cómo configuro el Makefile para cada testbench?**  
    Se debe parametrizar con una variable SIM que reciba el nombre del archivo testbench, y generar salidas .vcd con nombres diferentes según el módulo probado.

15. **¿Cómo puedo validar que el RX Buffer detecta correctamente el fin de cadena?**  
    Se envía una secuencia que incluya el caracter de fin de línea (ejemplo: \n o 0x0A). El buffer debe activar la señal end_of_str en esa condición.

16. **¿Cuál es la ventaja de encapsular el PWM con un pwm_ctrl en lugar de usar pwm.v directamente?**  
    pwm_ctrl añade la capacidad de escalar frecuencia y de validar la configuración con un pulso de cfg_valid, lo que mejora el control desde comandos UART.

17. **¿Cómo se conecta el parser con el PWM en el top?**  
    El duty_cycle, freq_div y enable_pwm generados por cmd_parser se conectan directamente a las entradas de pwm_ctrl.

18. **¿Qué debe hacer el uart_tx en el sistema?**  
    Debe transmitir respuestas o mensajes de confirmación cuando el sistema recibe un comando válido. Esto permite verificar por software que el hardware reconoció el dato.

19. **¿Qué ocurre si el buffer se llena en la práctica?**  
    La señal full se activa, y si se siguen escribiendo datos, se puede perder información. Por eso es clave que el top active rd_en automáticamente cuando hay datos disponibles.

20. **¿Qué tamaño de buffer es recomendable?**  
    Depende del uso. Para comandos pequeños (como D50), un buffer de 16 bytes es suficiente. Si se esperan cadenas largas, se recomienda ampliar a 64 o 128 bytes.

21. **¿Cómo puedo observar la diferencia entre distintos valores de duty_cycle?**  
    En GTKWave, la señal pwm_out debe cambiar de ancho de pulso: valores pequeños generan pulsos muy estrechos y valores grandes generan pulsos anchos.

22. **¿Qué pasa si envío un duty mayor a 100?**  
    El diseño en pwm_ctrl descarta valores mayores a 99, por lo que se mantiene el último duty válido.

23. **¿Por qué usamos freq_scale.v en lugar de poner directamente divisores?**  
    Porque permite generar ticks ajustables combinando divisiones por potencias de 2 y por 5, lo cual da flexibilidad en la frecuencia resultante.

24. **¿Qué debe ocurrir cuando envío el comando "E0"?**  
    La señal enable_pwm se desactiva y la salida pwm_out queda permanentemente en bajo.

25. **¿Cómo garantizamos que el PWM tenga resolución del 1%?**  
    Se fija el periodo en 100 ticks dentro del pwm.v, así cada incremento en duty representa 1% del ciclo útil.

26. **¿Qué debe hacer el testbench de top.v al iniciar?**  
    Debe generar reset, enviar una secuencia de comandos UART y observar si el PWM responde correctamente en frecuencia y duty.

27. **¿Qué diferencia hay entre probar módulos individuales y el top.v?**  
    Probar módulos individuales permite aislar errores y depurar más fácil, mientras que probar el top verifica la integración completa.

28. **¿Qué limitaciones tiene este sistema en hardware real?**  
    Depende del reloj disponible y del baudrate UART. El diseño funciona bien en simulación, pero en FPGA se deben ajustar divisores según frecuencia del reloj maestro.

29. **¿Cómo podemos mejorar la robustez del parser?**  
    Añadiendo validación de caracteres y detección de errores de comando, por ejemplo, ignorando datos que no empiecen con "D", "F", o "E".

30. **¿Qué ocurre si los comandos llegan muy rápido?**  
    El buffer debe absorberlos, pero si se llena puede haber pérdida. Una mejora sería implementar handshaking para pausar la transmisión hasta que haya espacio.

31. **¿Qué pasos finales validan que el proyecto funciona completo?**  
    Simular tb_top, enviar una secuencia como "D30", "F02", "E1", y observar en GTKWave que el PWM genera una señal activa con 30% duty y la frecuencia esperada. Eso confirma que todo el flujo UART → PWM → TX funciona.

---

## Reflexión sobre el Uso de IA

La IA fue clave para:

- Generar módulos y testbenches iniciales.
- Depurar errores y problemas de simulación.
- Documentar y estructurar el proyecto.

Sin embargo, el criterio personal fue esencial para validar la lógica y ajustar detalles. La IA fue un asistente de productividad, no un sustituto del razonamiento técnico.

---

## Recomendaciones y Mejoras

- **Buffer:** Para comandos cortos, 16 bytes son suficientes; para cadenas largas, ampliar a 64/128 bytes.
- **Robustez:** Añadir validación de comandos y manejo de errores en el parser.
- **Integración:** Probar módulos individuales y el sistema completo para asegurar funcionamiento.
- **Hardware real:** Ajustar divisores según el reloj maestro de la FPGA.

---

## Validación Final

Simula `tb_top`, envía comandos como:

```
D30
F02
E1
```

Verifica en GTKWave que el PWM genera una señal activa con 30% duty y la frecuencia esperada.

---

**Autor: Cristian David Chalaca Salas**  
Proyecto académico UNAL - Diseño y Verificación de Sistemas Digitales  
2025
