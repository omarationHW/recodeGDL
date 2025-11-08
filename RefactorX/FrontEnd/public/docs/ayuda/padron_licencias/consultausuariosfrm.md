# Consulta de Usuarios del Sistema

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite consultar información de los usuarios registrados en el sistema de licencias. Proporciona búsqueda por usuario, nombre o departamento, y muestra datos completos de cada usuario incluyendo su vigencia, fechas relevantes y ubicación organizacional.

### ¿Para qué sirve en el proceso administrativo?
- Consulta información de usuarios del sistema
- Valida vigencia de usuarios (activos o dados de baja)
- Muestra dependencia y departamento de cada usuario
- Permite búsqueda por usuario, nombre o área
- Facilita auditoría de accesos al sistema
- Proporciona información de contacto (teléfono)
- Registra historial de altas y bajas de usuarios

### ¿Quiénes lo utilizan?
- Administradores del sistema
- Jefes de Padrón y Licencias
- Personal de Recursos Humanos
- Auditores internos
- Supervisores que requieren validar permisos de usuarios
- Personal de soporte técnico

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### BÚSQUEDA POR USUARIO

1. **Selección de pestaña**
   - Usuario activa TabSheet1 "Búsqueda por Usuario"

2. **Captura de usuario**
   - Usuario ingresa nombre de usuario en Edit1
   - Presiona botón "Buscar" (BitBtn1)

3. **Validación de entrada**
   - Sistema verifica que campo Edit1 no esté vacío
   - Si está vacío: Muestra mensaje "Debes indicar el usuario..."

4. **Ejecución de consulta**
   - Sistema construye query compleja uniendo tablas:
     - usuarios (u)
     - deptos (d) - departamentos
     - c_dependencias (c)
   - Filtra por: WHERE usuario = "[texto ingresado]"

5. **Cierre y apertura de query**
   - Cierra query usuarios si estaba abierta
   - Limpia SQL previo
   - Ejecuta nueva consulta
   - Abre resultados

6. **Visualización de resultados**
   - Muestra datos en grid:
     - Descripción de dependencia
     - Nombre del departamento
     - Teléfono del departamento
     - Usuario
     - Nombres completos
     - Fecha de alta
     - Fecha de baja (si aplica)
     - Fecha de captura
     - Usuario que capturó
   - Muestra estado de vigencia (Vigente/Cancelado) en color

#### BÚSQUEDA POR NOMBRE

1. **Selección de pestaña**
   - Usuario activa TabSheet2 "Búsqueda por Nombre"

2. **Captura de nombre**
   - Usuario ingresa nombre (parcial o completo) en Edit2
   - Presiona botón "Buscar" (BitBtn2)

3. **Validación de entrada**
   - Sistema verifica que campo Edit2 no esté vacío
   - Si está vacío: Muestra mensaje "Debes indicar el nombre..."

4. **Ejecución de consulta**
   - Construye query con MATCHES para búsqueda parcial:
     - WHERE u.nombres MATCHES "[texto]*"
   - Permite encontrar nombres que inicien con el texto buscado

5. **Visualización de resultados**
   - Muestra todos los usuarios cuyo nombre coincida
   - Puede devolver múltiples resultados

#### BÚSQUEDA POR DEPENDENCIA Y DEPARTAMENTO

1. **Selección de pestaña**
   - Usuario activa TabSheet3 "Búsqueda por Área"

2. **Selección de dependencia**
   - Usuario selecciona dependencia en RxLookupEdit1
   - Al seleccionar dependencia, limpia campo de departamento

3. **Selección de departamento**
   - Usuario selecciona departamento en RxLookupEdit2
   - Departamentos se filtran por dependencia seleccionada

4. **Validación de selección**
   - Sistema verifica que ambos campos estén llenos
   - Si falta alguno: Muestra "Debes indicar la dependencia y el departamento"

5. **Ejecución de consulta**
   - Presiona botón "Buscar" (BitBtn3)
   - Consulta por cvedepto (código de departamento)
   - Muestra todos los usuarios de ese departamento

6. **Visualización de resultados**
   - Lista todos los usuarios del departamento seleccionado

#### INDICADOR DE VIGENCIA

1. **Evento de cambio de registro**
   - Al navegar entre registros, se dispara usuariosDsDataChange

2. **Verificación de fecha de baja**
   - Si campo fecbaj tiene valor:
     - Label vigencia se pone rojo
     - Texto = "Cancelado"
   - Si campo fecbaj está vacío:
     - Label vigencia se pone verde
     - Texto = "Vigente"

3. **Visualización clara**
   - Usuario identifica rápidamente si usuario está activo o dado de baja

### ¿Qué información requiere el usuario?

#### Para búsqueda por usuario:
- **Nombre de usuario** (obligatorio): Login o identificador del usuario

#### Para búsqueda por nombre:
- **Nombre** (obligatorio): Nombre completo o parcial de la persona

#### Para búsqueda por área:
- **Dependencia** (obligatorio): Área mayor (ej: Padrón y Licencias)
- **Departamento** (obligatorio): Departamento específico dentro de la dependencia

### ¿Qué validaciones se realizan?

1. **Validación de campos obligatorios**
   - Usuario: Requiere nombre de usuario
   - Nombre: Requiere nombre a buscar
   - Área: Requiere tanto dependencia como departamento

2. **Validación de existencia**
   - Si no encuentra resultados, grid queda vacío
   - No muestra mensaje de error, solo resultado vacío

3. **Validación de vigencia visual**
   - Color verde = Usuario activo
   - Color rojo = Usuario dado de baja

4. **Integridad referencial**
   - Une correctamente usuarios con departamentos y dependencias
   - Muestra solo información consistente

### ¿Qué documentos genera?
Ninguno. Este es un módulo de consulta que solo visualiza información de usuarios.

## Tablas de Base de Datos

### Tablas que Consulta

1. **usuarios (u)**
   - Tabla principal de usuarios del sistema
   - Campos consultados:
     - usuario: Login del usuario
     - nombres: Nombre completo
     - fecalt: Fecha de alta en el sistema
     - fecbaj: Fecha de baja (NULL si está vigente)
     - feccap: Fecha de captura del registro
     - capturo: Usuario que dio de alta
     - cvedepto: Código del departamento
     - cvedependencia: Código de la dependencia

2. **deptos (d)**
   - Catálogo de departamentos
   - Campos consultados:
     - cvedepto: Código único del departamento
     - nombredepto: Nombre del departamento
     - telefono: Teléfono del departamento

3. **c_dependencias (c)**
   - Catálogo de dependencias
   - Campos consultados:
     - id_dependencia: Código de la dependencia
     - descripcion: Nombre de la dependencia

### Tablas que Modifica
**Ninguna**. Este módulo es de solo lectura.

## Stored Procedures
Este módulo no utiliza stored procedures. Realiza consultas directas mediante queries SQL con JOINs.

## Impacto y Repercusiones

### ¿Qué registros afecta?
Ninguno. Es un módulo de solo consulta.

### ¿Qué cambios de estado provoca?
Ninguno. No realiza cambios en el sistema.

### ¿Qué documentos/reportes genera?
Ninguno. Solo muestra información en pantalla.

### ¿Qué validaciones de negocio aplica?

1. **Verificación de vigencia**
   - Identifica usuarios activos vs. dados de baja
   - Visualización clara mediante colores

2. **Integridad organizacional**
   - Muestra correctamente la estructura organizacional
   - Vincula usuarios con su departamento y dependencia

## Flujo de Trabajo

### Flujo de búsqueda por usuario

```
INICIO
  ↓
Abrir TabSheet1
  ↓
Abrir tablas:
  - dependencias
  - deptos
  ↓
Usuario ingresa nombre de usuario en Edit1
  ↓
Clic en "Buscar"
  ↓
¿Edit1 vacío? → SÍ → Mensaje "Debes indicar el usuario"
  ↓ NO
Cerrar query usuarios
  ↓
Limpiar SQL
  ↓
Construir query:
  SELECT c.descripcion, d.nombredepto, d.telefono,
         u.usuario, u.nombres, u.fecalt, u.fecbaj,
         u.feccap, u.capturo
  FROM usuarios u, deptos d, c_dependencias c
  WHERE usuario = "texto"
    AND d.cvedepto = u.cvedepto
    AND c.id_dependencia = cvedependencia
  ↓
Abrir query
  ↓
¿Encontró datos? → NO → Grid vacío
  ↓ SÍ
Mostrar en grid
  ↓
Evaluar vigencia:
  ¿fecbaj tiene valor? → SÍ → Label rojo "Cancelado"
  ↓ NO
  Label verde "Vigente"
  ↓
FIN
```

### Flujo de búsqueda por nombre

```
INICIO
  ↓
Abrir TabSheet2
  ↓
Usuario ingresa nombre en Edit2
  ↓
Clic en "Buscar"
  ↓
¿Edit2 vacío? → SÍ → Mensaje "Debes indicar el nombre"
  ↓ NO
Cerrar query usuarios
  ↓
Construir query con MATCHES:
  WHERE u.nombres MATCHES "texto*"
  ↓
Abrir query
  ↓
Mostrar resultados (puede ser múltiples)
  ↓
FIN
```

### Flujo de búsqueda por área

```
INICIO
  ↓
Abrir TabSheet3
  ↓
Usuario selecciona dependencia (RxLookupEdit1)
  ↓
Al seleccionar dependencia:
  - Limpiar RxLookupEdit2
  ↓
Usuario selecciona departamento (RxLookupEdit2)
  ↓
Clic en "Buscar"
  ↓
¿Ambos campos llenos? → NO → Mensaje "Debes indicar dependencia y departamento"
  ↓ SÍ
Obtener cvedepto del departamento seleccionado
  ↓
Construir query:
  WHERE u.cvedepto = [cvedepto]
  ↓
Abrir query
  ↓
Mostrar todos los usuarios del departamento
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Tres métodos de búsqueda**
   - Por usuario: Búsqueda exacta por login
   - Por nombre: Búsqueda parcial con MATCHES
   - Por área: Búsqueda por ubicación organizacional

2. **Indicador visual de vigencia**
   - Color verde = Usuario activo (puede acceder al sistema)
   - Color rojo = Usuario dado de baja (acceso bloqueado)

3. **Búsqueda parcial por nombre**
   - MATCHES permite encontrar nombres que inicien con el texto
   - Ejemplo: "Juan" encuentra "Juan Pérez", "Juana García", etc.

4. **Cascada en selección de área**
   - Al cambiar dependencia, se limpia departamento
   - Asegura selección consistente

### Restricciones

1. **Solo lectura**
   - No permite modificar usuarios desde este módulo
   - Alta/baja de usuarios debe hacerse en módulo administrativo

2. **Búsqueda exacta por usuario**
   - No permite búsqueda parcial en TabSheet1
   - Debe ser nombre de usuario exacto

3. **Requiere ambos campos en búsqueda por área**
   - No permite buscar solo por dependencia
   - Requiere departamento específico

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos de consulta de usuarios
- Acceso de lectura a tablas:
  - usuarios
  - deptos
  - c_dependencias (dependencias)

### Recomendaciones de uso

1. **Para verificar vigencia de usuario**
   - Buscar por nombre de usuario
   - Verificar color del indicador de vigencia
   - Si está cancelado (rojo), el usuario no puede acceder

2. **Para localizar usuarios**
   - Si conoce el login: Usar TabSheet1
   - Si solo conoce el nombre: Usar TabSheet2
   - Si conoce el área: Usar TabSheet3

3. **Para auditoría**
   - Revisar fechas de alta y baja
   - Verificar quién dio de alta al usuario (campo capturo)
   - Validar que usuarios activos estén en departamentos correctos

4. **Para soporte técnico**
   - Localizar rápidamente información de contacto
   - Verificar a qué departamento pertenece un usuario
   - Validar que tenga acceso activo

5. **Para gestión de personal**
   - Listar usuarios por departamento
   - Identificar usuarios dados de baja
   - Validar estructura organizacional en sistema

### Información que muestra

**En el grid de resultados:**
- **Descripción**: Nombre de la dependencia (ej: Padrón y Licencias)
- **Nombre Depto**: Nombre del departamento específico
- **Teléfono**: Teléfono del departamento
- **Usuario**: Login del usuario
- **Nombres**: Nombre completo de la persona
- **Fec. Alta**: Cuándo se dio de alta en el sistema
- **Fec. Baja**: Cuándo se dio de baja (vacío si está vigente)
- **Fec. Captura**: Cuándo se registró en el sistema
- **Capturó**: Quién dio de alta al usuario

**Indicador de vigencia:**
- **Verde "Vigente"**: Usuario activo, puede acceder al sistema
- **Rojo "Cancelado"**: Usuario dado de baja, acceso bloqueado
