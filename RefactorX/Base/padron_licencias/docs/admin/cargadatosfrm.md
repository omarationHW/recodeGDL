# Visualización de Datos Catastrales

## Descripción General

### ¿Qué hace este módulo?
Este módulo es una ventana de consulta que muestra información catastral detallada de un predio asociado a una licencia comercial. Presenta datos del avalúo, construcciones, propietarios y características físicas del inmueble en pestañas organizadas.

### ¿Para qué sirve en el proceso administrativo?
- Visualiza información catastral del predio donde opera la licencia
- Presenta datos de avalúos y construcciones
- Muestra características físicas del inmueble
- Permite consultar datos de condominios cuando aplica
- Facilita la verificación de información para otorgamiento de licencias
- Proporciona contexto catastral para decisiones administrativas

### ¿Quiénes lo utilizan?
- Personal de Padrón y Licencias
- Personal de ventanilla
- Inspectores que revisan trámites
- Valuadores
- Personal que relaciona licencias con predios

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Apertura del módulo**
   - Sistema recibe como parámetro la cuenta catastral
   - Se abre automáticamente al consultar una licencia

2. **Carga inicial de datos**
   - Sistema activa pestaña de "Datos Generales" (TabSheet2)
   - Consulta tabla de avalúos con la cuenta catastral
   - Consulta tabla de construcciones

3. **Validación de tipo de predio**
   - **Si es condominio** (variable condom = true):
     - Título de ventana: "CUENTA DE CONDOMINIO"
     - Muestra datos especiales de condominio
   - **Si NO es condominio**:
     - Título de ventana vacío (predios normales)

4. **Determinación de fuente de datos**
   - **Si tiene avalúo de condominio Y subpredio = 0**:
     - Usa datos de tabla AvaCondoQry
     - Muestra información del condominio principal
   - **Si NO**:
     - Usa datos de tabla avaluos normal
     - Muestra información del predio individual

5. **Carga de construcciones**
   - Sistema carga información de construcciones del predio
   - Asocia construcciones a la fuente correcta (condominio o predio normal)

6. **Validación de tipo de movimiento catastral**
   - **Si Cvemovtoava = 15 o 9** (fusiones/subdivisiones):
     - Muestra área de cartografía
     - Hace visible label y campo de área
   - **Si es otro tipo**:
     - Oculta información de cartografía

7. **Visualización en pestañas**
   - Usuario puede navegar entre pestañas:
     - TabSheet1: Información de propietarios y documentos
     - TabSheet2: Datos generales del predio
     - TabSheet3: Información catastral detallada
     - TabSheet4: Construcciones
     - TabSheet5: Documentos y observaciones

8. **Cierre del módulo**
   - Usuario cierra la ventana
   - Sistema cierra todas las queries abiertas:
     - construcqry
     - avacondoqry
     - AreaCartoQry

### ¿Qué información requiere el usuario?
**Ninguna**. Este es un módulo de solo consulta que recibe automáticamente:
- Cuenta catastral desde el módulo que lo invoca
- Variable condom (indica si es condominio)
- Datos de avalúo ya cargados

### ¿Qué validaciones se realizan?

1. **Validación de tipo de predio**
   - Detecta si es condominio o predio normal
   - Selecciona fuente de datos apropiada

2. **Validación de subpredio**
   - Si subpredio = 0 y existe avalúo de condominio:
     - Usa datos del condominio principal
   - Si subpredio > 0:
     - Usa datos del predio individual

3. **Validación de movimiento catastral**
   - Detecta movimientos especiales (fusión/subdivisión)
   - Muestra u oculta información de cartografía según corresponda

4. **Integridad de datos**
   - Vincula correctamente construcciones con avalúo
   - Asocia datos según tipo de predio (condominio o normal)

### ¿Qué documentos genera?
Ninguno. Este es un módulo exclusivamente de consulta y visualización.

## Tablas de Base de Datos

### Tablas que Consulta

1. **avaluosqry / avaluos**
   - Información principal del avalúo del predio
   - Datos del propietario
   - Características del terreno
   - Valores catastrales
   - Tipo de movimiento (cvemovtoava)
   - Subpredio

2. **AvaCondoQry**
   - Datos específicos de avalúos de condominios
   - Se usa cuando el predio es parte de un condominio
   - Campo clave: cvecatnva (cuenta catastral nueva)

3. **construcqry**
   - Información de construcciones del predio
   - Superficie construida
   - Tipo de construcción
   - Características físicas
   - Valores de construcción

4. **AreaCartoQry**
   - Información de cartografía
   - Áreas calculadas por cartografía
   - Se muestra solo para movimientos tipo 15 o 9

5. **convctaQry**
   - Conversión de cuentas catastrales
   - Obtiene cvecatnva (cuenta catastral nueva)
   - Relaciona cuentas antiguas con nuevas

### Tablas que Modifica
**Ninguna**. Este módulo es de solo lectura, no realiza modificaciones en la base de datos.

## Stored Procedures
Este módulo no utiliza stored procedures. Realiza solo consultas directas de lectura.

## Impacto y Repercusiones

### ¿Qué registros afecta?
Ninguno. Es un módulo de consulta que no modifica registros.

### ¿Qué cambios de estado provoca?
Ninguno. No realiza cambios en el sistema.

### ¿Qué documentos/reportes genera?
Ninguno. Solo visualiza información en pantalla.

### ¿Qué validaciones de negocio aplica?

1. **Consistencia de datos de condominio**
   - Asegura mostrar datos correctos según tipo de predio
   - Diferencia entre condominio y predio normal

2. **Visualización contextual**
   - Muestra información de cartografía solo cuando es relevante
   - Adapta interfaz según tipo de movimiento catastral

## Flujo de Trabajo

```
INICIO
  ↓
Módulo recibe parámetros:
  - Cuenta catastral
  - Variable condom
  ↓
Activar pestaña "Datos Generales"
  ↓
Consultar AvaCondoQry
  (con cvecatnva)
  ↓
¿Es condominio? → SÍ → Título = "CUENTA DE CONDOMINIO"
  ↓ NO             ↓
Título = ""  <───┘
  ↓
¿Tiene avalúo condominio Y subpredio=0?
  ↓ SÍ                    ↓ NO
Usar AvaCondoQry     Usar avaluosqry normal
  ↓                      ↓
  └──────┬──────────────┘
         ↓
Conectar construcqry a fuente seleccionada
  ↓
Abrir construcqry
  ↓
¿Cvemovtoava = 15 o 9? → SÍ → Abrir AreaCartoQry
  ↓ NO                          Mostrar área cartografía
Ocultar área cartografía
  ↓
Mostrar todas las pestañas con datos
  ↓
Usuario navega entre pestañas
  (Solo consulta, no edita)
  ↓
Usuario cierra ventana
  ↓
Cerrar queries:
  - construcqry
  - avacondoqry
  - AreaCartoQry
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Módulo de solo lectura**
   - No permite editar información
   - Solo visualiza datos catastrales
   - Información es de referencia para licencias

2. **Manejo especial de condominios**
   - Detecta automáticamente si es condominio
   - Ajusta fuente de datos según corresponda
   - Identifica visualmente las cuentas de condominio

3. **Información contextual**
   - Muestra datos de cartografía solo cuando son relevantes
   - Tipos de movimiento 15 y 9 requieren área de cartografía

4. **Integración con catastro**
   - Datos provienen del sistema de catastro
   - Refleja información actualizada de avalúos
   - Vincula licencias con predios

### Restricciones

1. **Solo lectura**
   - No se puede modificar ningún dato
   - Cambios deben hacerse en módulo de catastro

2. **Dependencia de datos de catastro**
   - Requiere que exista avalúo del predio
   - Sin datos catastrales, no muestra información

3. **Invocación desde otro módulo**
   - No es módulo independiente
   - Debe ser llamado desde otro proceso

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos de lectura a tablas:
  - avaluos
  - AvaCondoQry
  - construcqry
  - AreaCartoQry
  - convctaQry

### Recomendaciones de uso

1. **Como módulo de consulta**
   - Usar para verificar datos del predio antes de aprobar licencia
   - Validar que licencia corresponda al predio correcto
   - Revisar características físicas del inmueble

2. **Información relevante a verificar**
   - Superficie del terreno vs. superficie autorizada para licencia
   - Tipo de construcción vs. giro solicitado
   - Propietario catastral vs. solicitante de licencia
   - Ubicación exacta del predio

3. **Para condominios**
   - Verificar si es condominio principal o subpredio
   - Validar que licencia corresponda a la unidad correcta
   - Revisar áreas comunes vs. áreas privativas

4. **Coordinación con catastro**
   - Si hay inconsistencias, reportar a área de catastro
   - No intentar corregir datos desde este módulo
   - Mantener comunicación entre departamentos

### Información que muestra (por pestaña)

**TabSheet1 - Propietarios:**
- Nombre del propietario
- Documentos de propiedad
- Información legal del predio

**TabSheet2 - Datos Generales:**
- Cuenta catastral
- Ubicación del predio
- Superficie del terreno
- Colindancias
- Valores catastrales

**TabSheet3 - Información Catastral:**
- Zona catastral
- Tipo de predio
- Uso de suelo
- Servicios públicos
- Área de cartografía (si aplica)

**TabSheet4 - Construcciones:**
- Grid con detalle de construcciones
- Superficie por construcción
- Tipo de construcción
- Estado de conservación
- Valores de construcción

**TabSheet5 - Documentos:**
- Observaciones catastrales
- Notas relevantes
- Documentos asociados
