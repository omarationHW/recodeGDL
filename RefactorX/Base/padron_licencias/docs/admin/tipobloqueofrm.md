# Tipo de Bloqueo

## Descripción General

### ¿Qué hace este módulo?
Este módulo presenta una ventana de diálogo que permite al usuario seleccionar el tipo de bloqueo que se aplicará a una licencia o anuncio, así como ingresar el motivo de dicho bloqueo.

### ¿Para qué sirve en el proceso administrativo?
Sirve para documentar y justificar las razones por las cuales se está bloqueando una licencia o anuncio. El bloqueo es una medida administrativa que impide que se realicen ciertas operaciones sobre el registro (como renovación, modificación o trámites) hasta que se resuelva la situación que motivó el bloqueo.

### ¿Quiénes lo utilizan?
- Personal administrativo autorizado del área de Licencias
- Supervisores del departamento de Catastro
- Usuarios con permisos especiales para bloquear/desbloquear licencias

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?
1. El usuario abre el formulario de bloqueo desde otro módulo (por ejemplo, al intentar bloquear una licencia)
2. El sistema muestra una ventana modal con:
   - Un catálogo de tipos de bloqueo (cargado de la tabla `c_tipobloqueo`)
   - Un campo de texto para ingresar el motivo detallado del bloqueo
3. El usuario selecciona el tipo de bloqueo del catálogo desplegable
4. El usuario escribe el motivo específico del bloqueo en el campo de texto
5. El usuario confirma la operación o la cancela
6. Si confirma, el sistema retorna los valores seleccionados al módulo que llamó este formulario

### ¿Qué información requiere el usuario?
- **Tipo de bloqueo** (selección obligatoria del catálogo)
- **Motivo del bloqueo** (texto libre, obligatorio)

### ¿Qué validaciones se realizan?
- Se verifica que se haya seleccionado un tipo de bloqueo válido
- Se verifica que se haya ingresado un motivo (el campo no debe estar vacío)
- El formulario no permite continuar sin completar ambos campos

### ¿Qué documentos genera?
Este módulo no genera documentos por sí mismo, sino que captura información que será utilizada por otros módulos para:
- Registrar el bloqueo en la base de datos
- Generar reportes históricos de bloqueos
- Documentar las razones del bloqueo en el expediente de la licencia/anuncio

## Tablas de Base de Datos

### Tabla Principal
**c_tipobloqueo**: Catálogo de tipos de bloqueo disponibles en el sistema
- Contiene los diferentes tipos de bloqueo que pueden aplicarse (suspensión temporal, clausura, incumplimiento normativo, etc.)

### Tablas Relacionadas

#### Tablas que consulta:
- **c_tipobloqueo**: Lee los tipos de bloqueo disponibles para mostrarlos en el catálogo desplegable

#### Tablas que modifica:
Este módulo NO modifica directamente ninguna tabla. Solo captura información que será utilizada por el módulo que lo invocó para realizar las actualizaciones correspondientes en:
- Tabla de licencias o anuncios (campo de bloqueo)
- Tabla de historial de bloqueos (si existe)

## Stored Procedures
Este módulo no consume stored procedures directamente.

## Impacto y Repercusiones

### ¿Qué registros afecta?
De manera indirecta (a través del módulo que lo invoca):
- Registros de licencias que se estén bloqueando
- Registros de anuncios que se estén bloqueando
- Registros históricos de bloqueos y desbloqueos

### ¿Qué cambios de estado provoca?
No provoca cambios de estado directamente, pero la información capturada será utilizada para:
- Cambiar el estado de "bloqueado" de una licencia de 0 a un valor específico
- Registrar en el historial la fecha, usuario, tipo y motivo del bloqueo
- Impedir operaciones sobre la licencia/anuncio bloqueado

### ¿Qué documentos/reportes genera?
- No genera documentos directamente
- La información capturada se usa en reportes de:
  - Licencias bloqueadas
  - Historial de bloqueos
  - Auditorías administrativas

### ¿Qué validaciones de negocio aplica?
- Obligatoriedad de seleccionar un tipo de bloqueo
- Obligatoriedad de ingresar un motivo
- Retorno de valores válidos al módulo invocador

## Flujo de Trabajo

### Descripción del flujo completo del proceso
1. **Invocación**: Otro módulo del sistema llama a este formulario cuando necesita bloquear una licencia/anuncio
2. **Inicialización**:
   - Se abre el formulario como ventana modal
   - Se carga el catálogo de tipos de bloqueo de la base de datos
   - Se posiciona en el último registro del catálogo
3. **Captura de información**:
   - Usuario selecciona tipo de bloqueo del desplegable
   - Usuario escribe el motivo en el campo de texto
4. **Confirmación**:
   - Si presiona "Aceptar": se validan los campos y se retornan los valores
   - Si presiona "Cancelar": se retornan valores vacíos/nulos
5. **Cierre**: El formulario se cierra y devuelve el control al módulo invocador
6. **Procesamiento**: El módulo invocador procesa la información recibida y actualiza las tablas correspondientes

## Notas Importantes

### Consideraciones especiales
- Este es un formulario de **diálogo modal**, lo que significa que bloquea la interacción con otras ventanas hasta que se cierre
- Los datos capturados **no se guardan directamente** en la base de datos desde este módulo
- Es un módulo **auxiliar** o **helper** que solo captura información
- El formulario se auto-destruye al cerrarse (action:=cafree) para liberar memoria

### Restricciones
- No puede cerrarse sin seleccionar alguna opción (Aceptar o Cancelar)
- La selección del tipo de bloqueo está limitada a los valores existentes en el catálogo `c_tipobloqueo`
- No permite agregar nuevos tipos de bloqueo desde este formulario

### Permisos necesarios
- Este formulario es invocado por otros módulos que ya tienen sus propias validaciones de permisos
- No implementa validaciones de permisos propias
- Los permisos se validan en el módulo que invoca este formulario

### Integración con otros módulos
Este formulario es utilizado típicamente por:
- Módulo de consulta de licencias
- Módulo de consulta de anuncios
- Módulo de modificación de licencias
- Cualquier otro módulo que necesite bloquear/desbloquear registros

### Mejores prácticas de uso
- Siempre proporcionar un motivo claro y específico del bloqueo
- El motivo debe incluir suficiente información para que otros usuarios comprendan la razón
- Utilizar terminología administrativa estándar en la descripción del motivo
- El motivo ingresado quedará registrado en el historial y puede ser consultado posteriormente
