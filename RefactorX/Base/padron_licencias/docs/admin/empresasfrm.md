# Gestion de Empresas

## Descripcion General

### Que hace este modulo
El modulo de Gestion de Empresas permite administrar el catalogo de empresas relacionadas con el sistema de licencias. Una empresa es una entidad que puede ser propietaria de multiples licencias o actuar como representante legal en tramites de licencias comerciales.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Registrar nuevas empresas en el sistema
- Mantener actualizada la informacion de empresas existentes
- Generar reportes de empresas registradas
- Asignar numeros unicos de empresa de forma automatica
- Consultar el historial y vigencia de empresas

### Quienes lo utilizan
- Personal del Departamento de Licencias y Padrones
- Personal de Recaudacion que procesa pagos de empresas
- Supervisores que requieren consultar informacion de empresas
- Personal de Atencion al Ciudadano para verificar datos

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Alta de Nueva Empresa:**
1. El usuario presiona el boton "Agregar"
2. El sistema abre un formulario de captura
3. Se debe capturar la siguiente informacion obligatoria:
   - Nombre o razon social de la empresa
   - Representante legal
   - Domicilio completo (calle, numero exterior/interior, colonia)
   - Telefono de contacto
   - RFC (Registro Federal de Contribuyentes)
   - Fecha de otorgamiento (se establece automaticamente a la fecha actual)
4. El sistema asigna automaticamente un numero consecutivo de empresa
5. Al presionar "Aceptar", el sistema guarda la informacion en transaccion
6. Se genera automaticamente un registro de saldos para la empresa

**Edicion de Empresa Existente:**
1. El usuario selecciona una empresa del listado
2. Presiona el boton "Editar"
3. Modifica los datos necesarios
4. Presiona "Aceptar" para guardar cambios

**Consulta de Empresas:**
- El usuario puede navegar por todas las empresas registradas
- Puede ordenar y filtrar el listado
- Puede imprimir la informacion de una empresa especifica

### Que informacion requiere el usuario

**Datos Obligatorios:**
- Nombre de la empresa
- Domicilio (calle con clave)
- Representante legal
- Datos de contacto (telefono)

**Datos Opcionales pero Recomendados:**
- RFC
- Correo electronico
- Fecha de otorgamiento (se asigna automatica)
- Numero de licencia asociada (se asigna en 0 inicialmente)

### Que validaciones se realizan

1. **Asignacion Automatica de Numero de Empresa:**
   - El sistema consulta el ultimo numero de empresa utilizado
   - Incrementa en 1 el consecutivo
   - Actualiza el parametro del sistema con el nuevo numero
   - Asigna el numero a la nueva empresa

2. **Valores por Defecto:**
   - Vigencia se establece en "V" (Vigente)
   - Licencia se inicializa en 0
   - Recaudacion se establece en 0
   - ID de giro se establece en 338 (giro predeterminado)
   - Coordenadas X y Y se establecen en 0
   - Clave de cuenta se establece en 0

3. **Transaccionalidad:**
   - La insercion se realiza dentro de una transaccion
   - Si ocurre un error, se hace rollback automatico
   - Se valida que se cree el registro de saldos

### Que documentos genera
- **Reporte de Empresa Individual:** Imprime una ficha completa con todos los datos de la empresa seleccionada, incluyendo:
  - Numero de empresa
  - Razon social
  - Representante legal
  - Domicilio completo
  - Datos de contacto
  - Fecha de registro
  - Estado de vigencia

## Tablas de Base de Datos

### Tabla Principal
- **emp (empresas):** Tabla que almacena toda la informacion de las empresas registradas en el sistema. Cada empresa puede estar asociada a multiples licencias.

### Tablas Relacionadas

**Tablas que Consulta:**
- **parametros_lic:** Para obtener y actualizar el consecutivo de numero de empresa
- **c_calles:** Para validar y obtener la clave de calle del domicilio

**Tablas que Modifica:**
- **emp (empresas):** Inserta nuevas empresas o actualiza datos existentes
- **parametros_lic:** Actualiza el campo "empresa" con el nuevo consecutivo
- **saldoslic:** Crea un registro inicial de saldos para cada nueva empresa

## Stored Procedures

- **insertsaldoslic:** Procedimiento que se ejecuta automaticamente al crear una nueva empresa. Su proposito es:
  - Crear el registro inicial en la tabla de saldos de licencias
  - Inicializar todos los campos monetarios en cero
  - Asociar el registro con el ID de licencia de la empresa

## Impacto y Repercusiones

### Que registros afecta
- **Registro de Empresa Nueva:**
  - Crea un nuevo registro en la tabla de empresas
  - Incrementa el contador de empresas en parametros del sistema
  - Genera registro inicial en saldos de licencias

- **Registro de Empresa Existente:**
  - Modifica los datos de la empresa seleccionada
  - No afecta los registros historicos o de saldos

### Que cambios de estado provoca
- Al crear una empresa, su estado inicial es "V" (Vigente)
- La empresa queda disponible para ser asociada a licencias y tramites
- Se habilita para operaciones de recaudacion

### Que documentos/reportes genera
- Ficha de empresa con formato oficial
- Listado incluye logo institucional
- Datos completos de contacto y representacion legal

### Que validaciones de negocio aplica
1. **Consecutivo Automatico:** Garantiza que no haya duplicidad en numeros de empresa
2. **Integridad Transaccional:** Si falla cualquier parte del proceso, no se crea la empresa
3. **Inicializacion de Saldos:** Cada empresa nueva inicia con saldos en cero
4. **Asignacion de Valores Default:** Establece valores iniciales consistentes para todos los registros

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Flujo de Alta de Empresa:**
```
1. Usuario abre modulo de Empresas
2. Click en boton "Agregar"
3. Sistema deshabilita navegacion y otros botones
4. Usuario captura datos de la empresa
5. Usuario presiona "Aceptar"
6. Sistema inicia transaccion
7. Sistema consulta ultimo numero de empresa
8. Sistema incrementa consecutivo
9. Sistema actualiza parametros
10. Sistema asigna valores por defecto
11. Sistema guarda registro de empresa
12. Sistema ejecuta SP para crear saldos
13. Sistema confirma transaccion (commit)
14. Sistema recarga listado de empresas
15. Sistema muestra ultima empresa creada
```

**Flujo de Edicion:**
```
1. Usuario selecciona empresa del listado
2. Click en boton "Editar"
3. Sistema habilita campos para modificacion
4. Usuario modifica datos necesarios
5. Usuario presiona "Aceptar"
6. Sistema guarda cambios
7. Sistema regresa a modo consulta
```

**Flujo de Impresion:**
```
1. Usuario selecciona empresa del listado
2. Click en boton "Imprimir"
3. Sistema genera reporte con datos actuales
4. Sistema envia a impresora o visor de reportes
```

## Notas Importantes

### Consideraciones especiales

1. **Numero de Empresa es Unico e Irrepetible:**
   - Una vez asignado, el numero de empresa no puede modificarse
   - Es el identificador principal en todo el sistema
   - Se utiliza para relacionar con licencias y tramites

2. **Diferencia entre Empresa y Licencia:**
   - Una empresa puede tener CERO o MULTIPLES licencias
   - El numero de empresa es diferente al numero de licencia
   - Al crear la empresa, el campo "licencia" se inicializa en 0

3. **Giro Predeterminado 338:**
   - Se asigna un ID de giro 338 por defecto
   - Este giro puede ser modificado posteriormente
   - Representa una categoria generica de empresa

4. **Registro de Saldos:**
   - Es fundamental que se cree el registro en saldoslic
   - Si falla esta creacion, toda la transaccion se cancela
   - Permite llevar control financiero desde el primer momento

### Restricciones

1. **No se permite eliminar empresas:**
   - El sistema no incluye funcionalidad de eliminacion
   - Solo se puede modificar o marcar como no vigente

2. **Campos Requeridos:**
   - El nombre de la empresa es obligatorio
   - El domicilio debe tener al menos la calle

3. **Transaccionalidad:**
   - La creacion es atomica (todo o nada)
   - Si hay error en cualquier paso, se cancela todo

### Permisos necesarios

- **Agregar Empresa:** Requiere permisos de escritura en:
  - Tabla de empresas
  - Tabla de parametros
  - Tabla de saldos de licencias

- **Editar Empresa:** Requiere permisos de actualizacion en:
  - Tabla de empresas

- **Consultar/Imprimir:** Requiere permisos de lectura en:
  - Tabla de empresas
  - Catalogos relacionados (calles, giros)

### Impacto en otros modulos

- **Modulo de Licencias:** Utiliza el catalogo de empresas para asignar propietarios
- **Modulo de Tramites:** Referencia empresas en solicitudes
- **Modulo de Recaudacion:** Consulta empresas para aplicar pagos
- **Reportes Gerenciales:** Incluyen estadisticas de empresas registradas
