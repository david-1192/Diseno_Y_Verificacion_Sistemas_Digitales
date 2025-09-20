# Diseño de FSM e Implementación RTL con Entrada UART (a nivel de bit)

## Información de la Identificación
- Último dígito de mi ID: **5**
- Patrón binario (4 bits): **0101**

---

## 📦 Descripción General
Este proyecto implementa un **sistema detector de patrones** que identifica un valor de 4 bits dentro de un flujo serial recibido por **UART**.  
El patrón corresponde al último dígito de la identificación personal, convertido a binario.  

Cuando los últimos 4 bits coinciden con el patrón, el sistema genera un pulso `match = 1` durante **exactamente un ciclo de reloj de 25 MHz**.  

---

## 📊 Diagrama del Sistema

![Diagrama en bloques del detector de patrones con UART](Diagrama%20fsm_uart.drawio.png)

---

## ⚙️ Requerimientos de Diseño

1. **Generador de Baud-Rate**  
   - Derivar una señal de tick a partir del reloj de 25 MHz para muestrear bits a **115200 bps**.  

2. **Muestreador UART**  
   - Detectar el **bit de inicio** (flanco descendente `1 → 0`).  
   - Desplazar los **8 bits de datos** (ignorar el bit de parada).  
   - Entregar cada bit recibido al registro SIPO.  

3. **Registro SIPO**  
   - Implementar un **registro de desplazamiento de 8 bits** sincronizado con el tick de baud-rate.  
   - En cada nuevo bit, desplazar dentro del registro.  
   - Exponer los últimos 4 bits para detección.  

4. **Detector de Patrón**  
   - Circuito combinacional que compara los 4 bits menos significativos del SIPO con el patrón objetivo (`0101`).  
   - Si son iguales, activar `match = 1`.  
   - La señal `match` debe sincronizarse al dominio de reloj de 25 MHz y durar exactamente un ciclo.  

5. **Módulo Superior (Top)**  
   - Instanciar:  
     - Generador de baud-rate  
     - Muestreador UART  
     - Registro SIPO  
     - Detector de patrón  
     - Sincronizador  
   - Entregar un pulso `match` alineado al reloj de 25 MHz.  

6. **Testbenches**  
   - Un TB independiente para cada módulo y uno para el sistema completo.  
   - Casos a cubrir:  
     - Operación normal (detección correcta)  
     - Patrones solapados  
     - No coincidencias  
     - Comportamiento en reset  
     - Casos límite (ruido en bits de inicio/parada)  


## 📊 Resultados
- Se observaron ondas de simulación mostrando detecciones correctas del patrón.  
- Los pulsos `match` se sincronizaron al dominio del reloj de 25 MHz y duran exactamente un ciclo.  
- El sistema detecta coincidencias superpuestas correctamente.  

---

### 🤖 Reflexión sobre el uso de IA  

El uso de la IA fue de gran ayuda para organizar el proyecto, estructurar los módulos y generar rápidamente los testbenches. Me permitió ahorrar tiempo en tareas repetitivas y enfocarme en entender el diseño digital. Sin embargo, fue necesario revisar y ajustar manualmente algunos detalles, como la generación de archivos de simulación (`.vcd`) y la adaptación a mis herramientas específicas (`iverilog` y GTKwave). En conclusión, la IA fue un apoyo valioso, pero la validación final del código y la simulación dependieron de mi criterio técnico.  

---

## 🔍 Estrategias de Prompts para la Mejora del Proyecto  

Además de los prompts iniciales usados para estructurar el sistema, también se plantearon **estrategias de mejora** a través de preguntas clave.  

### 📌 Preguntas iniciales para llegar al diseño  
Estas 5 preguntas guiaron el proceso desde el contexto hasta el diseño final:  

1. ¿Cómo puedo implementar un generador de baud-rate que me permita muestrear la línea UART a 115200 bps partiendo de un reloj de 25 MHz?  
2. ¿Qué estrategia se recomienda para detectar el bit de inicio y extraer los bits de datos de una trama UART?  
3. ¿Cómo construir un registro de desplazamiento (SIPO) que me entregue siempre los últimos 8 bits recibidos y exponga los últimos 4 para la detección de patrones?  
4. ¿Qué lógica combinacional debo usar para comparar esos últimos 4 bits con el patrón `0101` correspondiente a mi dígito de identificación?  
5. ¿Cómo se integran todos estos bloques en un módulo superior que entregue un pulso `match` sincronizado con el reloj de 25 MHz?  

Estas preguntas fueron resueltas paso a paso, lo que permitió llegar al diseño base del sistema.  

---

### ⚡ Preguntas sobre posibles mejoras  
Posteriormente, con el sistema ya funcionando, se exploraron **mejoras de robustez y seguridad** mediante las siguientes 3 preguntas:  

1. ¿Cómo puedo hacer más robusta la detección del bit de inicio ante ruido o falsos flancos en la línea UART?  
2. ¿Qué mecanismo de sincronización se recomienda para asegurar que la señal `match` no genere metastabilidad al cruzar al dominio del reloj de 25 MHz?  
3. ¿Cómo podrían diseñarse testbenches más exhaustivos que incluyan ruido, patrones superpuestos y resets asíncronos para verificar la confiabilidad del sistema?  

En estas últimas 3 preguntas la IA fue **particularmente útil**, porque permitió reforzar el diseño con mayor tolerancia al ruido, un mejor tratamiento de la sincronización de señales entre dominios de reloj y estrategias de verificación más sólidas.  

