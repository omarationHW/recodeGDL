# Propietarios de Hologramas

## Descripcion General

### Que hace este modulo
El modulo de Propietarios de Hologramas administra el catalogo de contribuyentes que estan autorizados para recibir hologramas de seguridad. Es un catalogo independiente que registra nombre, domicilio y datos fiscales de los propietarios que pueden solicitar y recibir hologramas para sus establecimientos.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Mantener catalogo de propietarios autorizados para hologramas
- Registrar datos completos de contacto y ubicacion
- Facilitar seleccion de propietarios al autorizar hologramas
- Mantener registro de RFC y datos fiscales
- Administrar altas, bajas y modificaciones del catalogo
- Proporcionar lista de contribuyentes elegibles para hologramas

### Quienes lo utilizan
- Personal de Recaudacion que gestiona hologramas
- Administradores del sistema que dan altas de propietarios
- Supervisores que autorizan nuevos contribuyentes
- Personal de ventanilla que consulta contribuyentes

## Proceso Administrativo

### Como funciona el paso a paso

**Agregar Nuevo Propietario:**

1. Usuario presiona boton "Agregar"
2. Sistema habilita panel de captura (panel2)
3. Sistema deshabilita botones de navegacion
4. Sistema pone tabla en modo Insert
5. Usuario captura datos:
   - ID del Contribuyente (identificador unico)
   - Nombre completo
   - Primer apellido
   - Segundo apellido
   - Domicilio completo
   - RFC
   - Telefono
6. Usuario presiona "Aceptar"
7. Sistema guarda registro en base de datos
8. Sistema cierra panel de captura
9. Sistema refresca listado de propietarios
10. Sistema habilita botones de navegacion

**Modificar Propietario Existente:**

1. Usuario selecciona propietario del listado
2. Usuario presiona boton "Editar"
3. Sistema valida que haya registros
4. Si no hay registros, muestra mensaje y sale
5. Sistema habilita panel de captura con datos actuales
6. Sistema pone tabla en modo Edit
7. Usuario modifica los datos necesarios
8. Usuario presiona "Aceptar"
9. Sistema guarda cambios
10. Sistema cierra panel de captura
11. Sistema refresca listado

**Borrar Propietario:**

1. Usuario selecciona propietario del listado
2. Usuario presiona boton "Borrar"
3. Sistema muestra confirmacion: "Esta seguro de borrar el registro?"
4. Si usuario confirma (Yes):
   - Sistema elimina registro de la base de datos
   - Sistema actualiza listado automaticamente
5. Si usuario cancela (No):
   - No se realizan cambios

**Cancelar Operacion:**

1. Durante captura o edicion, usuario presiona "Cancelar"
2. Sistema descarta cambios no guardados
3. Sistema cierra panel de captura
4. Sistema regresa a modo consulta
5. Sistema habilita botones de navegacion

**Consultar Propietarios:**

- Usuario puede navegar por el listado completo
- Ver todos los propietarios registrados
- Ordenar por cualquier columna
- Buscar propietarios especificos

### Que informacion requiere el usuario

**Datos del Propietario:**
- **ID Contribuyente:** Identificador unico (clave)
- **Nombre:** Nombre(s) del propietario
- **Primer Apellido:** Apellido paterno
- **Segundo Apellido:** Apellido materno (opcional)
- **Domicilio:** Direccion completa
- **RFC:** Registro Federal de Contribuyentes
- **Telefono:** Numero de contacto

**Todos los campos son opcionales en interfaz, pero:**
- ID es clave primaria (debe ser unico)
- Se recomienda capturar nombre completo y domicilio
- RFC es importante para trazabilidad fiscal

### Que validaciones se realizan

1. **Existencia de Registros:**
   - Al editar, valida que haya al menos un registro
   - Si no hay registros, muestra mensaje y no permite editar

2. **Confirmacion de Eliminacion:**
   - Requiere confirmacion explicita del usuario
   - Previene eliminaciones accidentales
   - Mensaje claro: "Esta seguro de borrar el registro?"

3. **Unicidad de ID:**
   - Sistema garantiza ID unico via base de datos
   - No permite duplicados

4. **Integridad Referencial:**
   - No permite eliminar si tiene hologramas asociados
   - Protegido por llave foranea en tabla hologramas

### Que documentos genera
- **Ninguno:** Es un modulo de mantenimiento de catalogo
- No genera reportes ni documentos
- Los datos se usan en otros modulos (gestion de hologramas)

## Tablas de Base de Datos

### Tabla Principal
- **c_contribholog (catalogo de contribuyentes para hologramas):** Tabla que almacena propietarios autorizados para recibir hologramas

### Tablas Relacionadas

**Tablas que Consulta:**
- **c_contribholog:** Unica tabla consultada

**Tablas que Modifica:**
- **c_contribholog:**
  - INSERT al agregar nuevo propietario
  - UPDATE al modificar propietario existente
  - DELETE al borrar propietario

## Stored Procedures
- **Ninguno:** No utiliza procedimientos almacenados

## Impacto y Repercusiones

### Que registros afecta

**Al Agregar Propietario:**
- Inserta nuevo registro en c_contribholog
- Propietario queda disponible para autorizacion de hologramas
- Aparece en lista de seleccion de modulo de hologramas

**Al Modificar Propietario:**
- Actualiza datos en c_contribholog
- Hologramas ya autorizados mantienen referencia
- Cambios se reflejan inmediatamente

**Al Borrar Propietario:**
- Elimina registro de c_contribholog
- Solo permite si NO tiene hologramas asociados
- Error de llave foranea impide eliminacion si hay hologramas

### Que cambios de estado provoca
- **Ninguno en otros modulos**
- Solo afecta disponibilidad en lista de seleccion
- Hologramas existentes no se modifican

### Que documentos/reportes genera
- No genera documentos directamente
- Datos aparecen en recibos y reportes de hologramas

### Que validaciones de negocio aplica

1. **Integridad del Catalogo:**
   - Un propietario, un ID unico
   - Datos consistentes y completos

2. **Proteccion de Datos en Uso:**
   - No permite eliminar si tiene hologramas
   - Previene perdida de informacion

3. **Trazabilidad:**
   - RFC permite identificacion fiscal
   - Domicilio permite ubicacion fisica

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Alta de Nuevo Propietario**

```
1. SOLICITUD:
   a. Contribuyente solicita hologramas por primera vez
   b. No existe en catalogo de propietarios
   c. Personal de recaudacion debe darlo de alta

2. ACCESO AL CATALOGO:
   d. Personal abre modulo de Propietarios de Hologramas
   e. Sistema muestra listado actual
   f. Personal verifica que no existe (busca por nombre)

3. CAPTURA:
   g. Personal presiona "Agregar"
   h. Sistema habilita panel de captura
   i. Personal captura:
      - ID: 1001 (consecutivo siguiente disponible)
      - Nombre: JUAN
      - Primer Apellido: PEREZ
      - Segundo Apellido: GONZALEZ
      - Domicilio: AV JUAREZ 123 COL CENTRO
      - RFC: PEGJ800101ABC
      - Telefono: 3331234567
   j. Personal presiona "Aceptar"

4. GUARDADO:
   k. Sistema valida datos
   l. Sistema guarda en base de datos
   m. Sistema actualiza listado
   n. Nuevo propietario aparece en grid

5. USO POSTERIOR:
   o. Personal cierra modulo de propietarios
   p. Personal abre modulo de Gestion de Hologramas
   q. Al autorizar hologramas, nuevo propietario aparece en lista
   r. Personal puede seleccionarlo y continuar proceso
```

**Caso de Uso: Correccion de Datos**

```
1. DETECCION:
   a. Personal detecta error en datos de propietario
   b. RFC incorrecto o telefono desactualizado
   c. Requiere correccion

2. LOCALIZACION:
   d. Personal abre modulo de Propietarios
   e. Busca propietario en listado
   f. Selecciona registro a corregir

3. EDICION:
   g. Personal presiona "Editar"
   h. Sistema habilita panel con datos actuales
   i. Personal corrige RFC: PEGJ800101ABC → PEGJ800101XY3
   j. Personal actualiza telefono: 3331234567 → 3339876543
   k. Personal presiona "Aceptar"

4. ACTUALIZACION:
   l. Sistema guarda cambios
   m. Sistema actualiza listado
   n. Datos corregidos aparecen inmediatamente

5. VERIFICACION:
   o. Personal verifica cambios en listado
   p. Cierra modulo
   q. Cambios disponibles para otros usuarios
```

## Notas Importantes

### Consideraciones especiales

1. **Catalogo Independiente:**
   - No todos los contribuyentes del sistema estan aqui
   - Solo quienes estan autorizados para hologramas
   - Criterio de inclusion lo define el municipio

2. **ID Como Clave:**
   - ID debe ser unico y no reutilizable
   - Se recomienda usar consecutivos
   - No hay generacion automatica de ID

3. **Datos Minimos Recomendados:**
   - Nombre completo (para identificacion)
   - Domicilio (para notificaciones)
   - RFC (para temas fiscales)
   - Telefono (para contacto)

4. **Sin Historial:**
   - No mantiene log de cambios
   - Una vez modificado, datos anteriores se pierden
   - Si requiere auditoria, debe implementarse externamente

5. **Eliminacion Protegida:**
   - Sistema protege via llave foranea
   - Error de BD previene eliminacion si hay hologramas
   - Mensaje puede no ser amigable para usuario

### Restricciones

1. **No Permite Eliminar con Hologramas:**
   - Si propietario tiene hologramas autorizados o entregados
   - No se puede eliminar del catalogo
   - Primero deben eliminarse/cancelarse hologramas

2. **Sin Validacion de RFC:**
   - Sistema no valida formato de RFC
   - Responsabilidad del capturista verificar

3. **Sin Validacion de Duplicados por Nombre:**
   - Sistema no detecta nombres similares
   - Puede haber duplicidad si no se busca antes

4. **Cierre Automatico de Panel:**
   - Al aceptar o cancelar, panel se oculta
   - No hay opcion de mantenerlo abierto

### Permisos necesarios

- **Consultar:** Lectura en c_contribholog
- **Agregar:** INSERT en c_contribholog
- **Modificar:** UPDATE en c_contribholog
- **Eliminar:** DELETE en c_contribholog

### Integracion con otros modulos

**Modulos que Usan este Catalogo:**
- **Gestion de Hologramas:** Lista de propietarios para seleccion
- **Reportes de Hologramas:** Datos del propietario en reportes

**Flujo de Dependencia:**
```
1. Alta en Propietarios de Hologramas
2. Propietario disponible para autorizacion
3. Autorizacion de hologramas en Gestion de Hologramas
4. Entrega de hologramas
5. Reportes incluyen datos del propietario
```

### Importancia del Catalogo

- Base para control de hologramas
- Permite rastrear a quien se autorizan
- Facilita comunicacion con contribuyentes
- Proporciona datos para auditoria
- Soporta trazabilidad fiscal

### Mejores Practicas

1. **Antes de Agregar:**
   - Buscar si ya existe en catalogo
   - Verificar datos con documentos oficiales
   - Capturar RFC correctamente

2. **Al Capturar:**
   - Usar mayusculas para consistencia
   - Domicilio completo y claro
   - Telefono con 10 digitos

3. **Al Modificar:**
   - Verificar que cambios sean correctos
   - Documentar razon del cambio externamente

4. **Al Intentar Eliminar:**
   - Verificar primero si tiene hologramas
   - Si hay error, consultar tabla hologramas
   - Considerar inactivacion en lugar de eliminacion
