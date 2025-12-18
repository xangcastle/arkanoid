# **Arquitectura de la Nostalgia: Informe Técnico Exhaustivo para la Recreación Fidedigna de Arkanoid en Godot Engine**

## **1\. Introducción y Contextualización Técnica**

La recreación de un clásico de arcade como *Arkanoid* (Taito, 1986\) dentro de un motor contemporáneo como Godot Engine trasciende el mero ejercicio de programación; constituye un acto de preservación digital y un estudio profundo sobre la evolución de las mecánicas de juego. A diferencia de su predecesor espiritual, *Breakout* (Atari, 1976), *Arkanoid* introdujo una narrativa de ciencia ficción, una física de pelota matizada y un ecosistema de potenciadores (power-ups) que definieron el género de "rompeladrillos" (brick-breaker) durante décadas. Este informe técnico, diseñado para desarrolladores y preservacionistas digitales, aborda la reconstrucción del título con un enfoque en la fidelidad mecánica, la integridad narrativa y la arquitectura de software moderna en Godot 4.x.

El objetivo de este documento es proporcionar una hoja de ruta exhaustiva que cubra desde la adquisición ética y legal de activos hasta la implementación matemática de la física de rebote "pseudo-newtoniana" que caracterizaba a las máquinas arcade de los años 80\. Se analizará la disponibilidad de repositorios, se desglosará el "lore" o trasfondo narrativo a menudo ignorado, y se catalogarán meticulosamente los sistemas de ladrillos, enemigos y cápsulas de poder, todo ello fundamentado en la investigación de manuales originales, ingeniería inversa y documentación de la comunidad.

### **1.1 La Evolución del Hardware al Software: El Reto de Godot**

El desafío principal al portar *Arkanoid* a Godot reside en la traducción de lógica discreta basada en ciclos de reloj de procesadores Z80 (el hardware original de Taito) a un motor orientado a objetos y basado en nodos.1 En el hardware original, la detección de colisiones se realizaba comprobando la superposición de sprites en momentos específicos del barrido de pantalla. En Godot, disponemos de motores de física avanzados (PhysicsServer2D), pero el uso ingenuo de estos sistemas puede resultar en un comportamiento "demasiado realista" que traiciona la sensación de juego (game feel) del original. Por ejemplo, el uso de RigidBody2D para la pelota a menudo introduce una fricción y una conservación del momento angular indeseadas; la recreación fiel requiere un enfoque cinemático (CharacterBody2D) donde los vectores de rebote se calculen manualmente basándose en tablas de consulta de ángulos, replicando así el control preciso que los jugadores experimentaron en 1986\.2

### **1.2 El Controlador Vaus: De Analógico a Digital**

Un aspecto crítico de la experiencia original fue el controlador "spinner" o dial, que permitía un movimiento analógico preciso. La nave Vaus aceleraba proporcionalmente a la velocidad de rotación del dial.4 Al recrear esto en Godot para teclados o gamepads modernos, se debe implementar una curva de aceleración y fricción en el script del jugador para simular la inercia del dial físico, evitando que la nave se sienta ingrávida o excesivamente rígida.

## ---

**2\. Análisis de Repositorios y Estrategia de Adquisición de Activos**

El usuario ha solicitado explícitamente la localización de un repositorio que contenga "todos los assets, sprites y sonidos". Es imperativo abordar esta solicitud con una distinción clara entre la disponibilidad técnica y la legalidad de la propiedad intelectual.

### **2.1 La Realidad de los Repositorios de Código Abierto**

La investigación exhaustiva de plataformas como GitHub y GitLab revela una verdad fundamental: **no existe un repositorio público legal que contenga los sprites, texturas y sonidos originales extraídos (ripped) de la ROM de arcade de Taito de 1986**, debido a la protección activa de los derechos de autor (copyright). Los repositorios que intentan alojar estos archivos originales suelen ser objeto de avisos de eliminación DMCA.

Sin embargo, existen proyectos de ingeniería inversa y clones de código abierto que proporcionan la **estructura lógica** y activos "imitación" (look-alike) que son funcionalmente idénticos para el propósito de desarrollo. A continuación se detalla el análisis de los repositorios más relevantes identificados:

#### **2.1.1 Una1n/Arkanoid (Godot 4.x)**

Este es el repositorio más pertinente tecnológicamente para un desarrollo moderno.5

* **Arquitectura:** El proyecto está actualizado a Godot 4.2, lo que significa que utiliza la sintaxis moderna de GDScript (ej. @export, super()).  
* **Contenido de Activos:** Posee una carpeta assets estructurada, que incluye subdirectorios para shaders, scenes y globals. Aunque no incluye los sprites originales de Taito (por razones legales), incluye "placeholders" o activos libres que replican las dimensiones funcionales de la Vaus y los ladrillos.  
* **Valor Técnico:** Su implementación de addons/shaderV sugiere un enfoque avanzado para replicar los efectos visuales de tubo de rayos catódicos (CRT) y los brillos de neón característicos de los años 80\. Es la base de código recomendada para estudiar la estructura de nodos.

#### **2.1.2 mjablecnik/Godot-Arkanoid**

Un proyecto más antiguo, desarrollado presumiblemente en Godot 2 o 3\.6

* **Limitaciones:** La API de Godot ha cambiado drásticamente. Funciones como move\_and\_slide han alterado sus argumentos en Godot 4\. Intentar importar este proyecto directamente resultaría en numerosos errores de compilación.  
* **Utilidad:** Contiene lógica específica para la integración de anuncios móviles (admob) y gestión de vidas, lo cual es útil si el objetivo de la recreación es el despliegue en plataformas Android o iOS.

#### **2.1.3 ChrisGodfrey/Arkanoid (Unity)**

Aunque está escrito para Unity, este repositorio es valioso por su organización de activos de audio.7 A menudo, la lógica de denominación de archivos de sonido (ej. laser\_shoot.wav, brick\_hit\_metal.wav) en estos proyectos es un estándar de facto que ayuda a organizar el FileSystem en Godot.

### **2.2 Estrategia de Adquisición de Activos (Legal y Ética)**

Para obtener los activos visuales y sonoros necesarios sin infringir derechos de autor, se recomienda una estrategia híbrida utilizando paquetes de activos de dominio público y síntesis de audio.

#### **2.2.1 Sprites y Gráficos (OpenGameArt)**

Existen paquetes creados por la comunidad que replican el estilo visual de Arkanoid bajo licencias permisivas (CC-BY, CC0).

* Basic Arkanoid Pack (por Zealex) 8: Este es el recurso más completo y seguro legalmente. Contiene:  
  * **Ladrillos:** Sprites con el biselado "3D" característico, en toda la gama de colores (Rojo, Azul, Verde, Amarillo, Plata, Oro).  
  * **Vaus:** La nave en tres estados (Normal, Contraída, Expandida). Esto es crucial para implementar el potenciador "E" (Expand).  
  * **Pelota:** Variaciones de color para la pelota, útil para el modo "Disruption".  
* Psychedelic Colourful Arkanoid Assets 9: Ofrece una estética de alto contraste, ideal si se busca replicar el estilo visual de las secuelas como *Arkanoid: Doh It Again*, donde los fondos eran psicodélicos y abstractos.  
* Pico-8 Assets 10: Si la recreación busca un estilo "demake" de baja resolución (8-bit estricto), estos activos son ideales, aunque la resolución de arcade original era superior a la de Pico-8.

#### **2.2.2 Efectos de Sonido (SFX)**

El paisaje sonoro de *Arkanoid* es minimalista pero icónico. En Godot, se recomienda utilizar nodos AudioStreamPlayer con variaciones de pitch\_scale para evitar la repetición auditiva.

* **Rebote en Pala:** Un "ping" metálico agudo.  
* **Destrucción de Ladrillo:** Un sonido crujiente, similar a vidrio rompiéndose digitalmente.  
* **Láser:** Un sonido sintetizado descendente (pew-pew).  
* **Muerte (Vaus):** Una explosión ruidosa seguida de una melodía descendente.  
* **Voz de DOH:** La síntesis de voz original ("Doh... It... Again") es difícil de replicar. Se sugiere usar generadores de texto a voz (TTS) bitcrushed (baja tasa de bits) para emular el chip de sonido Yamaha YM2149 original.

## ---

**3\. El Archivo Narrativo: Lore y Trasfondo del Universo Arkanoid**

A menudo subestimado, *Arkanoid* posee una narrativa de ciencia ficción profunda que contextualiza la jugabilidad abstracta. Integrar este "lore" en la recreación de Godot —a través de escenas de introducción o textos flotantes— elevará el proyecto de un simple clon a un tributo fiel.

### **3.1 El Incidente de la Nave Madre**

La historia comienza en un futuro distante donde la humanidad viaja en inmensas naves colonia.

* **La Arkanoid:** El título del juego no se refiere a la pala, sino a la nave nodriza ("Mothership Arkanoid"). Esta nave es destruida por una fuerza desconocida durante su viaje interestelar.11  
* **La Vaus:** El jugador controla la nave de escape modelo **Vaus** (escrita a veces como "Vaws" en traducciones tempranas). La Vaus es eyectada de la Arkanoid momentos antes de su destrucción.  
* **El Laberinto Espacial:** En lugar de escapar a un lugar seguro, la Vaus es atrapada en una distorsión dimensional, un "espacio deformado" creado por el antagonista para probar o torturar a los supervivientes.11

### **3.2 El Antagonista: DOH (Dominate Over Hour)**

El enemigo final no es una simple pared de ladrillos, sino una entidad consciente.

* **Nomenclatura:** DOH es un acrónimo de **"Dominate Over Hour"** (Dominador sobre la Hora/Tiempo), lo que implica que la entidad tiene control sobre el tejido del espacio-tiempo.13 Esto explica las mecánicas de "Warp" (Saltar nivel) y el final del juego.  
* **Iconografía:** DOH se manifiesta visualmente como una cabeza de piedra gigante, similar a un Moai de la Isla de Pascua, pero con componentes biomecánicos. En las secuelas, revela brazos mecánicos y un cuerpo completo. Es una amalgama de tecnología antigua y alienígena.

### **3.3 El Ciclo Temporal y los Finales**

El análisis de los finales de las distintas versiones revela una trama cíclica y metafísica.

* **Final Arcade (Bucle Temporal):** Al derrotar a DOH en la ronda 33, el juego no ofrece una victoria tradicional. El tiempo comienza a fluir hacia atrás. La Vaus escapa de la dimensión distorsionada solo para regresar a la Arkanoid, que se reconstruye a partir de sus escombros.1 El texto final advierte que "el viaje solo ha comenzado", atrapando al jugador en un bucle eterno.  
* **El 13º Amanecer Estelar (Final Verdadero):** En la secuela de SNES (*Doh It Again*), se rompe este ciclo. El comandante de la flota registra una entrada final: "Fecha: El 13º Amanecer Estelar... Hemos encontrado nuestro hogar largamente buscado. No repetiremos los errores del pasado... DOH se ha ido para siempre, desterrado al olvido".13

### **3.4 Implementación Narrativa en Godot**

Para reflejar este lore en su proyecto:

1. **Intro Cinemática:** Cree una escena Intro.tscn que utilice AnimationPlayer para mostrar sprites simples de la nave nodriza explotando y la Vaus saliendo despedida.  
2. **Shader de Distorsión:** Aplique un shader de distorsión de pantalla (efecto "warp") al completar cada nivel para simular el viaje a través de la dimensión de DOH.  
3. **Diálogo de Jefe:** Antes de la batalla final, utilice un nodo Label con una fuente pixelada para mostrar los mensajes crípticos de DOH.

## ---

**4\. Mecánicas de Juego y Reglas: La Física del Entretenimiento**

La recreación de la "sensación" de *Arkanoid* depende de la implementación precisa de reglas físicas que difieren de la realidad newtoniana. En Godot, esto se gestiona mediante scripts en GDScript que manipulan vectores de velocidad.

### **4.1 La Vaus (Jugador)**

* **Movimiento:** Estrictamente horizontal (Eje X).  
* **Inercia:** A diferencia de *Breakout*, la Vaus tiene una aceleración y desaceleración perceptibles.  
  * *Implementación en Godot:* No mueva la pala estableciendo position.x directamente. Utilice una velocidad (velocity.x) que se interpolan (lerp) hacia la velocidad objetivo basada en la entrada (Input.get\_axis). Esto simula el peso de la nave.  
* **Colisión:** La Vaus no es un rectángulo plano. Mecánicamente, actúa como si tuviera una superficie convexa.

### **4.2 La Pelota y el "Efecto Inglés" (Reflection)**

El núcleo del juego es cómo rebota la pelota en la pala. Un rebote simple (bounce()) es insuficiente.

* **Mecánica de Ángulo Variable:** El ángulo de rebote depende de **dónde** golpea la pelota en la pala, no del ángulo de incidencia.  
  * **Centro de la Pala:** La pelota rebota verticalmente o conserva su ángulo horizontal.  
  * **Bordes de la Pala:** La pelota sale disparada con un ángulo agudo y mayor velocidad horizontal.  
* **Fórmula para Godot:**  
  GDScript  
  \# Fragmento conceptual para \_physics\_process  
  var diferencia\_x \= centro\_pelota.x \- centro\_pala.x  
  var ancho\_pala \= colision\_pala.shape.extents.x  
  var factor\_rebote \= diferencia\_x / (ancho\_pala / 2\) \# Rango de \-1.0 a 1.0  
  var angulo\_nuevo \= factor\_rebote \* ANGULO\_MAXIMO \# Ej. 60 grados  
  vector\_velocidad \= Vector2.UP.rotated(deg\_to\_rad(angulo\_nuevo)) \* velocidad\_actual

  Esta lógica permite a los jugadores "apuntar" la pelota hacia ladrillos específicos, una habilidad crítica en niveles avanzados.15

### **4.3 Sistema de Velocidad Progresiva**

La pelota no mantiene una velocidad constante.

* **Incrementos:** La velocidad aumenta tras:  
  1. Un número fijo de rebotes en la pala (para evitar estancamientos).  
  2. Golpear ladrillos de alto nivel (Rojos/Naranjas).16  
  3. Capturar ciertos items.  
* **Límite:** Debe existir una constante MAX\_SPEED en el script para evitar que la pelota atraviese colisionadores (efecto "tunneling"). En Godot, active la propiedad Continuous CD (Detección de Colisión Continua) en el CharacterBody2D de la pelota para mitigar este riesgo a altas velocidades.

### **4.4 Mecánica de Láser (Potenciador L)**

Cuando la Vaus se transforma en modo Láser:

* **Disparo:** El jugador puede disparar dos proyectiles simultáneos.  
* **Restricción:** Máximo de 2 balas en pantalla. Esto obliga al jugador a apuntar y evita el "spam" de disparos.  
* **Daño:** Los láseres destruyen ladrillos normales instantáneamente pero requieren múltiples impactos para los ladrillos plateados. Los dorados son inmunes.

### **4.5 Mecánica de Captura (Potenciador C)**

Conocido como "Sticky" o "Catch".

* **Comportamiento:** Al contactar la pala, la velocidad de la pelota se vuelve Vector2.ZERO.  
* **Anclaje:** La pelota debe moverse solidariamente con la pala. En Godot, esto se puede lograr emparentando (reparent) el nodo de la pelota a la Vaus temporalmente, o actualizando su position.x en cada frame basándose en el desplazamiento de la Vaus.2

## ---

**5\. Catálogo Exhaustivo de Ladrillos y Puntuación**

La jerarquía de los ladrillos (Space Walls) es estricta y define la economía de puntos del juego. Los ladrillos miden típicamente 16x8 píxeles en la resolución original.

### **5.1 Ladrillos de Color (Estándar)**

Se destruyen con **un solo impacto**. Su valor en puntos depende de su color, que a su vez depende de la fila que ocupan (de abajo hacia arriba)..19

| Color del Ladrillo | Puntos | Comportamiento Adicional |
| :---- | :---- | :---- |
| **Blanco** | 50 | Nivel más bajo. Riesgo mínimo. |
| **Naranja** | 60 |  |
| **Cian (Celeste)** | 70 |  |
| **Verde** | 80 |  |
| **Rojo** | 90 | A menudo desencadena un aumento de velocidad de la pelota. |
| **Azul** | 100 |  |
| **Rosa (Magenta)** | 110 |  |
| **Amarillo** | 120 | Nivel más alto. Mayor riesgo debido al tiempo de retorno de la pelota. |

### **5.2 Ladrillos Especiales**

#### **Ladrillo Plateado (Silver)**

* **Apariencia:** Metálico, brillante.  
* **Durabilidad:** Requiere múltiples impactos para destruirse. La resistencia aumenta progresivamente según el nivel (Round).19  
  * Rondas 1-8: 2 golpes.  
  * Rondas 9-16: 3 golpes.  
  * Rondas 17-24: 4 golpes.  
  * Rondas 25+: 5 golpes.  
* **Puntuación Dinámica:** 50 puntos \* Número de Ronda.  
  * *Análisis:* Esto convierte a los ladrillos plateados en los objetos más valiosos del juego tardío (ej. en la Ronda 30, valen 1.500 puntos), incentivando a los jugadores expertos a arriesgarse por ellos.

#### **Ladrillo Dorado (Gold)**

* **Apariencia:** Oro macizo.  
* **Durabilidad:** Infinita (Indestructible).  
* **Función:** Actúan como obstáculos de terreno. No bloquean la finalización del nivel. El nivel termina cuando todos los ladrillos *destructibles* han desaparecido.

#### **Ladrillos Regenerativos (Variante)**

En *Revenge of Doh*, aparecen ladrillos plateados con muescas que se regeneran si no se destruyen rápidamente, añadiendo presión temporal.22

## ---

**6\. Lista Exhaustiva de Potenciadores (Power-Ups)**

Las cápsulas de poder son la variable estratégica clave. Caen aleatoriamente (o predeterminadas por nivel) al destruir ladrillos. Solo un potenciador puede estar activo a la vez (excepto la Vida Extra).

### **6.1 Lista Clásica (Arcade 1986\)**

| Letra | Color | Nombre | Efecto y Mecánica de Implementación en Godot |
| :---- | :---- | :---- | :---- |
| **S** | Naranja | **Slow** (Lento) | Reduce la velocidad de la pelota a su valor base mínimo. Es vital cuando la pelota alcanza velocidades incontrolables. |
| **L** | Rojo | **Laser** | Transforma la Vaus. Permite disparar rayos con el botón de acción. Requiere instanciar escenas LaserProjectile.tscn desde nodos Marker2D en la Vaus. |
| **C** | Verde | **Catch** (Atrapar) | La pelota se adhiere a la pala. Permite reposicionar el tiro. Se desactiva al disparar la pelota. |
| **E** | Azul | **Expand** (Expandir) | Alarga la Vaus (aprox. 1.5x). En Godot, cambie el Sprite y, crucialmente, escale el CollisionShape2D en el eje X. |
| **D** | Cian | **Disruption** (Disrupción) | Divide la pelota en **tres** copias.21 El jugador no pierde una vida mientras quede al menos una pelota en juego. Requiere un gestor de grupo ("Balls") para verificar la condición de derrota. |
| **B** | Rosa | **Break** (Romper/Salto) | Abre una puerta de "Warp" en el lateral derecho. Si la Vaus entra, el nivel se completa inmediatamente (+10,000 puntos). |
| **P** | Gris | **Player** (Vida) | Otorga una vida extra. Muy rara. |

### **6.2 Potenciadores de Secuelas y Variantes**

Para una recreación completa o expandida, considere estos items de *Arkanoid: Doh It Again*:

* **M (Mega):** La pelota se vuelve roja y atraviesa los ladrillos sin rebotar (perforante).  
* **T (Twin):** Crea una "sombra" de la Vaus que se mueve en paralelo.  
* **G (Giga/Ghost):** Variante del Catch con magnetismo.

## ---

**7\. Inteligencia Artificial: Enemigos y Obstáculos**

A diferencia de *Breakout*, *Arkanoid* presenta enemigos móviles que descienden desde escotillas superiores. No atacan directamente, pero actúan como peligros cinéticos.24

### **7.1 Catálogo de Enemigos (Nombres de Lore)**

1. **Konerd:**  
   * *Forma:* Geométrica, similar a una molécula o prisma giratorio.  
   * *Comportamiento:* Flota en diagonales simples, rebotando en las paredes.  
   * *Godot:* CharacterBody2D con velocidad constante y rebote al colisionar con WorldBoundary.  
2. **Pyradok:**  
   * *Forma:* Pirámide segmentada.  
   * *Comportamiento:* Movimiento en zig-zag cerrado.  
   * *Godot:* Se puede implementar animando un PathFollow2D sobre una curva sinusoidal predefinida.  
3. **Tri-Sphere:**  
   * *Forma:* Tres esferas orbitando un núcleo invisible.  
   * *Comportamiento:* Pulsa (cambia de radio) mientras desciende. Aumenta la dificultad al cambiar su tamaño de colisión dinámicamente.  
4. **Opopo:**  
   * *Forma:* Similar a una medusa robótica u ovoide.  
   * *Comportamiento:* Movimiento errático o aleatorio.

### **7.2 Reglas de Interacción Enemiga**

* **Pelota vs Enemigo:** El enemigo es destruido (se reproduce animación de explosión). La pelota rebota. Importante: El rebote en un enemigo suele añadir un factor aleatorio al ángulo, desestabilizando la trayectoria prevista por el jugador.  
* **Vaus vs Enemigo:** Si el enemigo toca la pala, la Vaus es destruida instantáneamente y se pierde una vida.  
* **Láser vs Enemigo:** El enemigo es destruido. Otorga puntos (generalmente 100 pts).

## ---

**8\. Guía de Implementación Técnica en Godot**

Para estructurar un proyecto de esta magnitud (estimado en miles de líneas de código y decenas de escenas), se debe seguir una arquitectura modular.

### **8.1 Estructura del Proyecto**

res://  
├── assets/  
│ ├── sprites/ (Atlas de texturas para Vaus, Ladrillos, Enemigos)  
│ ├── audio/ (SFX y Música de fondo)  
│ └── fonts/ (Fuentes estilo pixel-art)  
├── scenes/  
│ ├── core/  
│ │ ├── GameManager.tscn (Singleton para estado global)  
│ │ └── Main.tscn  
│ ├── entities/  
│ │ ├── Vaus.tscn (CharacterBody2D)  
│ │ ├── Ball.tscn (CharacterBody2D con lógica de rebote)  
│ │ ├── Brick.tscn (StaticBody2D con variante de color exportable)  
│ │ └── PowerUp.tscn (Area2D)  
│ └── levels/  
│ └── Leveldata\_01.tres (Recurso personalizado para diseño de nivel)  
└── scripts/  
├── StateMachine.gd  
└── LevelLoader.gd

### **8.2 Solución al Problema del "Tunneling"**

Un problema común en recreaciones de Arkanoid es que, a altas velocidades, la pelota "atraviesa" los ladrillos o la pala porque su desplazamiento por frame (velocity \* delta) es mayor que el grosor del objeto colisionador.

* **Solución 1 (Godot 4):** Utilizar ShapeCast2D. Antes de mover la pelota, lance un ShapeCast en la dirección del movimiento con longitud igual a la velocidad. Si detecta colisión, mueva la pelota al punto de impacto exacto.  
* **Solución 2:** Aumentar los pasos de física (physics\_ticks\_per\_second) en la configuración del proyecto de 60 a 120 o 240, aunque esto incrementa la carga de CPU.

### **8.3 Generación de Niveles por Datos**

No coloque los ladrillos manualmente en el editor. Cree un sistema de análisis de datos.26

* Utilice imágenes pequeñas (ej. 11x20 píxeles) donde cada píxel representa un ladrillo.  
* Lea el color del píxel en un script LevelLoader.  
* Si el píxel es rojo (\#FF0000), instancie un Brick.tscn, asigne el tipo "Rojo" y colóquelo en las coordenadas correspondientes (x \* ancho\_ladrillo, y \* alto\_ladrillo).  
* Esto permite diseñar niveles rápidamente en programas como Paint o Photoshop.

### **8.4 El Desafío del Jefe Final (DOH)**

Para la Ronda 33, deshabilite el generador de ladrillos e instancie la escena BossDoh.tscn.

* **Hitbox Compleja:** DOH necesita múltiples áreas de colisión. El cuerpo puede ser invulnerable; solo la boca o los ojos reciben daño.  
* **Gestión de Estado:** Implemente una máquina de estados finitos (FSM) para el jefe:  
  * *Estado IDLE:* Flotando, leve oscilación.  
  * *Estado ATTACK:* Genera proyectiles (telarañas o aros de energía) que descienden hacia la Vaus.  
  * *Estado DAMAGE:* Al ser golpeado, cambia el shader a blanco/rojo parpadeante y reproduce el sonido característico.

## **9\. Conclusión**

La recreación de *Arkanoid* es una lección magistral de diseño de juegos. Exige rigor matemático para la física de la pelota, creatividad arquitectónica para el sistema de potenciadores y sensibilidad artística para capturar la atmósfera opresiva pero colorida de su mundo. Al adherirse a las especificaciones detalladas en este informe —desde la puntuación exacta de un ladrillo plateado en la ronda 30 hasta la implementación de la fricción en el controlador Vaus— el resultado no será una simple copia, sino un artefacto de software que respeta y preserva la memoria de uno de los grandes hitos de la historia del arcade.

#### **Works cited**

1. Arkanoid \- Wikipedia, accessed December 17, 2025, [https://en.wikipedia.org/wiki/Arkanoid](https://en.wikipedia.org/wiki/Arkanoid)  
2. Pong \- Ball is being dragged when paddle moves on the same direction \- Godot Forum, accessed December 17, 2025, [https://forum.godotengine.org/t/pong-ball-is-being-dragged-when-paddle-moves-on-the-same-direction/113365](https://forum.godotengine.org/t/pong-ball-is-being-dragged-when-paddle-moves-on-the-same-direction/113365)  
3. Ball gets stuck instead of bouncing using bounce() and move\_and\_collide() \- Godot Forum, accessed December 17, 2025, [https://forum.godotengine.org/t/ball-gets-stuck-instead-of-bouncing-using-bounce-and-move-and-collide/88102](https://forum.godotengine.org/t/ball-gets-stuck-instead-of-bouncing-using-bounce-and-move-and-collide/88102)  
4. Taito NES Vaus Controller zero-tool de-jittering method \- AtariAge Forums, accessed December 17, 2025, [https://forums.atariage.com/topic/290452-taito-nes-vaus-controller-zero-tool-de-jittering-method/](https://forums.atariage.com/topic/290452-taito-nes-vaus-controller-zero-tool-de-jittering-method/)  
5. Una1n/Arkanoid: Arkanoid clone made in Godot 4 \- GitHub, accessed December 17, 2025, [https://github.com/Una1n/Arkanoid](https://github.com/Una1n/Arkanoid)  
6. mjablecnik/Godot-Arkanoid: My first game created in Godot ... \- GitHub, accessed December 17, 2025, [https://github.com/mjablecnik/Godot-Arkanoid](https://github.com/mjablecnik/Godot-Arkanoid)  
7. A simple Arkanoid clone in Unity. \- GitHub, accessed December 17, 2025, [https://github.com/chrisgodfrey/Arkanoid](https://github.com/chrisgodfrey/Arkanoid)  
8. Basic Arkanoid pack \- OpenGameArt.org |, accessed December 17, 2025, [https://opengameart.org/content/basic-arkanoid-pack](https://opengameart.org/content/basic-arkanoid-pack)  
9. Psychedelic Colourful Arkanoid Assets \- OpenGameArt.org |, accessed December 17, 2025, [https://opengameart.org/content/psychedelic-colourful-arkanoid-assets](https://opengameart.org/content/psychedelic-colourful-arkanoid-assets)  
10. Arkanoid Pico-8 Assets \- OpenGameArt.org |, accessed December 17, 2025, [https://opengameart.org/content/arkanoid-pico-8-assets](https://opengameart.org/content/arkanoid-pico-8-assets)  
11. Arkanoid \- Angelfire, accessed December 17, 2025, [https://www.angelfire.com/jazz/greensadan/arkanoid.html](https://www.angelfire.com/jazz/greensadan/arkanoid.html)  
12. Arkanoid \- FAQ \- NES \- By AWing\_Pilot \- GameFAQs, accessed December 17, 2025, [https://gamefaqs.gamespot.com/nes/563383-arkanoid/faqs/41196](https://gamefaqs.gamespot.com/nes/563383-arkanoid/faqs/41196)  
13. Arkanoid: Doh It Again \- Wikipedia, accessed December 17, 2025, [https://en.wikipedia.org/wiki/Arkanoid:\_Doh\_It\_Again](https://en.wikipedia.org/wiki/Arkanoid:_Doh_It_Again)  
14. Nintendo Super NES Game Endings: Arkanoid: Doh it Again, accessed December 17, 2025, [http://www.world-of-nintendo.com/game\_endings/super\_nes/arkanoid\_doh\_it\_again.shtml](http://www.world-of-nintendo.com/game_endings/super_nes/arkanoid_doh_it_again.shtml)  
15. Arkanoid 1986 Arcade Game – History, Gameplay, and Legacy \- Bitvint, accessed December 17, 2025, [https://bitvint.com/pages/arkanoid](https://bitvint.com/pages/arkanoid)  
16. Retrogaming, Indie Games and Games Culture: The A To Z Of Atari \- B is For \#Retrogaming \#GamersUnite \- Games Freezer, accessed December 17, 2025, [https://www.gamesfreezer.co.uk/2016/01/a-to-z-of-atari-retrogaming-gamersunite\_7.html](https://www.gamesfreezer.co.uk/2016/01/a-to-z-of-atari-retrogaming-gamersunite_7.html)  
17. Breakout \- Codex Gamicus \- Humanity's collective gaming knowledge at your fingertips., accessed December 17, 2025, [https://gamicus.fandom.com/wiki/Breakout](https://gamicus.fandom.com/wiki/Breakout)  
18. That's A Paddlin' | Making Your First Game in Godot \- YouTube, accessed December 17, 2025, [https://www.youtube.com/watch?v=WM1egzjphTA](https://www.youtube.com/watch?v=WM1egzjphTA)  
19. Arkanoid \- Nintendo NES \- Manual \- gamesdatabase.org \- The Game Is Afoot Arcade, accessed December 17, 2025, [https://www.thegameisafootarcade.com/wp-content/uploads/2017/02/Arkanoid-Game-Manual.pdf](https://www.thegameisafootarcade.com/wp-content/uploads/2017/02/Arkanoid-Game-Manual.pdf)  
20. Arkanoid (Tandy) \- Color Computer Archive, accessed December 17, 2025, [https://colorcomputerarchive.com/repo/Documents/Manuals/Games/Arkanoid%20(Tandy).pdf](https://colorcomputerarchive.com/repo/Documents/Manuals/Games/Arkanoid%20\(Tandy\).pdf)  
21. Getting Good: Arkanoid \- PrimeTime Amusements, accessed December 17, 2025, [https://primetimeamusements.com/getting-good-arkanoid/](https://primetimeamusements.com/getting-good-arkanoid/)  
22. Getting Good \- Arkanoid: Revenge of Doh \- PrimeTime Amusements, accessed December 17, 2025, [https://primetimeamusements.com/getting-good-arkanoid-revenge-of-doh/](https://primetimeamusements.com/getting-good-arkanoid-revenge-of-doh/)  
23. Arkanoid \+4 \- Software Details \- Plus/4 World, accessed December 17, 2025, [http://plus4world.powweb.com/software/Arkanoid\_Plus4](http://plus4world.powweb.com/software/Arkanoid_Plus4)  
24. arkanoid, accessed December 17, 2025, [https://www.digitpress.com/library/manuals/nes/Arkanoid.pdf](https://www.digitpress.com/library/manuals/nes/Arkanoid.pdf)  
25. Arkanoid \- Atari Gaming Headquarters, accessed December 17, 2025, [https://www.atarihq.com/tsr/manuals/arkanoid.txt](https://www.atarihq.com/tsr/manuals/arkanoid.txt)  
26. Arkanoid Game Levels \- Aschenblog, accessed December 17, 2025, [http://nick-aschenbach.github.io/blog/2015/04/27/arkanoid-game-levels/](http://nick-aschenbach.github.io/blog/2015/04/27/arkanoid-game-levels/)