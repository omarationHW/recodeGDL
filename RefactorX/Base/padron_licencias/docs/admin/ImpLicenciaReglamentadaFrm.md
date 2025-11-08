# Impresión de Licencia Reglamentada

## Descripción General

### ¿Qué hace este módulo?
Genera la **impresión del documento oficial de una licencia reglamentada** (Clase D) con información detallada del establecimiento, propietario, características técnicas y adeudos. Es el formato oficial que se entrega al contribuyente al autorizar una licencia de giro especial.

### ¿Para qué sirve en el proceso administrativo?
- Imprimir documento oficial de licencia reglamentada autorizada
- Entregar comprobante formal al titular de la licencia
- Generar expediente físico de la licencia
- Documentar características técnicas autorizadas
- Mostrar estatus de adeudos al momento de impresión

### ¿Quiénes lo utilizan?
- **Personal de ventanilla**: Para entregar licencias autorizadas
- **Supervisores**: Para generar documentos oficiales
- **Archivo**: Para resguardo de expedientes

## Proceso Administrativo

**1. Captura de Licencia**
- Usuario ingresa número de licencia
- Presiona Enter

**2. Validación y Carga de Datos**
- Sistema busca licencia en base de datos
- Verifica que exista
- Verifica que NO esté bloqueada (bloqueado <> 1)
- Verifica que sea Clase D (giro reglamentado)
- Carga información completa:
  - Datos del propietario
  - Datos del inmueble
  - Giro comercial
  - Características técnicas
  - Cuenta catastral
  - Adeudos históricos

**3. Habilitación de Impresión**
- Si cumple validaciones: Habilita botón "Imprimir"
- Si no cumple: Botón permanece deshabilitado

**4. Proceso de Impresión**
- Click en "Imprimir"
- Sistema ejecuta stored procedure: **calc_adeudolic**
  - Calcula adeudos actuales de la licencia
  - Llena tabla temporal: **tmp_adeudolic**
- Determina tipo de documento:
  - Si asiento = 1: "LICENCIA NUEVA"
  - Si asiento <> 1: "MODIFICACIÓN DE LICENCIA"
- Determina si es giro especial:
  - Si reglamentada = 'S': "GIRO DE CONTROL ESPECIAL"
- Genera e imprime documento oficial

## Tablas de Base de Datos

### Tabla Principal
**licencias** - Información de la licencia

### Tablas que Consulta
1. **licencias** - Todos los datos de la licencia
2. **giro** (c_giros) - Información del giro comercial, campo reglamentada
3. **convcta** - Conversión de cuenta (clave catastral)
4. **tmp_adeudolic** - Tabla temporal con adeudos calculados
5. **QryZona** - Información de zona y subzona (código comentado)

### Tablas que Modifica

**1. tmp_adeudolic** (Tabla temporal - se recrea cada vez)
- El stored procedure calc_adeudolic llena esta tabla
- Contiene detalle de adeudos por año
- Se usa solo para el reporte, luego se limpia

### Tablas que NO modifica
- **NO modifica** tabla licencias
- **NO modifica** tabla giros
- **NO modifica** saldos
- Es un módulo de solo impresión

## Stored Procedures

**calc_adeudolic** (crítico)
- **Parámetro**: id_licencia (INTEGER)
- **Función**: Calcula y llena tabla temporal tmp_adeudolic con:
  - Año de adeudo
  - Concepto adeudado
  - Monto
  - Recargos
  - Total
- **Ejecución**:
  ```pascal
  calc_adeudolic.parambyname('id_licencia').AsInteger := licencia['id_licencia'];
  calc_adeudolic.Prepare;
  calc_adeudolic.ExecProc;
  calc_adeudolic.Unprepare;
  ```
- **Resultado**: Datos listos en tmp_adeudolic para el subreporte

## Impacto y Repercusiones

### ¿Qué registros afecta?
**NINGUNO** en tablas permanentes. Solo usa tabla temporal para cálculos.

### ¿Qué cambios de estado provoca?
**NINGUNO** - Es módulo de solo consulta e impresión

### ¿Qué documentos genera?

**Documento Oficial de Licencia Reglamentada (ppReport1):**

**Encabezado:**
- Membrete municipal
- Escudo
- Etiqueta: "LICENCIA NUEVA" o "MODIFICACIÓN DE LICENCIA"
- Etiqueta: "GIRO DE CONTROL ESPECIAL" (si aplica)
- Número de licencia (grande, visible)

**Sección 1: Datos del Titular**
- Nombre completo del propietario (con apellidos)
- RFC
- CURP (si está capturado)
- Domicilio del propietario completo

**Sección 2: Datos del Establecimiento**
- Actividad comercial / Giro
- Descripción del giro
- Ubicación completa del negocio
- Clave catastral (de convcta)

**Sección 3: Características Técnicas**
- Superficie construida
- Superficie autorizada
- Número de cajones de estacionamiento
- Número de empleados
- Inversión
- Aforo (capacidad)
- Horario autorizado
- Especificaciones (campo espubic)
- Observaciones (campo espubic - segundo memo)

**Sección 4: Subreporte de Adeudos**
- Tabla con columnas:
  - Año
  - Concepto
  - Monto adeudado
  - Total
- Solo si tiene adeudos
- Sumatoria de adeudos al final

**Pie:**
- Firmas autorizadas
- Sello oficial
- Fecha de emisión

### ¿Qué validaciones aplica?

**Validaciones Críticas:**
1. **Licencia Existe**: Verifica que el número exista en BD
2. **No Bloqueada**: Solo imprime si bloqueado <> 1
3. **Clase D**: Solo imprime giros clasificación = 'D'
4. **Combinación**: Las 3 validaciones deben cumplirse para habilitar impresión

**Validación Implícita:**
- Si no encuentra la licencia: licencia.recordcount = 0, termina
- Si está bloqueada: b_imprimir.enabled permanece false
- Si no es Clase D: b_imprimir.enabled permanece false

## Flujo de Trabajo

```
1. Usuario abre módulo
2. Sistema muestra pantalla con campo de licencia
3. Usuario captura número de licencia
4. Presiona Enter (FloatEdit1KeyPress)
5. Sistema ejecuta validación:

   5.1. Deshabilita botón imprimir
   5.2. Cierra queries abiertos
   5.3. Busca licencia:
        licencia.parambyname('licencia').asstring := FloatEdit1.text
        licencia.open
   5.4. ¿Licencia encontrada?
        NO → exit (termina, botón sigue deshabilitado)
        SÍ → Continúa

   5.5. Abre giro (liga por id_giro)
   5.6. Abre convcta (liga por cvecuenta)

   5.7. Verifica condiciones:
        ¿bloqueado = 1 OR clasificación <> 'D'?
        SÍ → exit (termina, botón sigue deshabilitado)
        NO → Continúa

   5.8. Habilita botón imprimir

6. Sistema muestra datos en pantalla para verificación
7. Usuario revisa información
8. Click en botón "Imprimir"

9. Sistema prepara impresión:

   9.1. Cierra tmp_adeudolic si está abierta

   9.2. Ejecuta calc_adeudolic:
        - Calcula adeudos de la licencia
        - Llena tabla temporal

   9.3. Abre tmp_adeudolic para el subreporte

   9.4. Determina etiquetas:
        IF licencia['asiento'] = 1 THEN
           etiqueta1.caption := 'LICENCIA NUEVA'
        ELSE
           etiqueta1.caption := 'MODIFICACIÓN DE LICENCIA'

        IF giro['reglamentada'] = 'S' THEN
           etiqueta3.caption := 'GIRO DE CONTROL ESPECIAL'
        ELSE
           etiqueta3.caption := ''

   9.5. Asigna número de licencia a etiqueta:
        etiqueta10.caption := LicenciaLicencia.asstring

   9.6. Cierra QryZona (código comentado)

   9.7. Refresca convcta:
        IF convcta.Active THEN convcta.Close
        convcta.ParamByName('cvecuenta').AsInteger := licenciacvecuenta.Value
        convcta.Open

   9.8. Envía a impresora:
        ppReport1.print

10. Documento impreso
11. FIN
```

## Notas Importantes

### Consideraciones Especiales

**1. Solo para Giros Clase D**
- Giros reglamentados / control especial
- Ejemplos: Bares, cantinas, cabarets, table dance, etc.
- Requieren regulación especial y vigilancia estricta
- Licencias con requisitos más estrictos

**2. Validación de Bloqueo**
- Si está bloqueada, NO permite imprimir
- Debe desbloquearse primero
- Protege contra entrega de licencias con problemas

**3. Stored Procedure calc_adeudolic**
- Cálculo complejo de adeudos
- Incluye recargos moratorios
- Se ejecuta cada vez que se imprime (datos actuales)
- Puede tardar si la licencia tiene muchos años de historial

**4. Tabla Temporal**
- tmp_adeudolic se recrea cada impresión
- No es histórico, es cálculo en tiempo real
- Solo existe durante la sesión

**5. Modificación vs Licencia Nueva**
- Campo asiento indica:
  - asiento = 1: Primera vez (licencia nueva)
  - asiento <> 1: Modificación de una existente
- Cambia la leyenda en el documento

**6. Giro de Control Especial**
- Campo reglamentada = 'S' en c_giros
- Aparece leyenda especial en documento
- Indica que requiere vigilancia y cumplimiento estricto

**7. Información de Convcta**
- Obtiene clave catastral
- Importante para ligas con catastro
- Se refresca antes de imprimir para datos actuales

### Restricciones
- Solo imprime licencias Clase D
- No imprime licencias bloqueadas
- No imprime si no existe la licencia
- No permite modificar datos (solo imprimir)

### Permisos Necesarios
- Usuario válido del sistema
- Permiso de consulta en tablas de licencias
- Acceso a impresora configurada
- Permiso para ejecutar stored procedure calc_adeudolic

### Uso Recomendado
- Imprimir al momento de entregar licencia autorizada
- Generar copia para expediente
- Reimprimir solo si se perdió original
- Verificar datos en pantalla antes de imprimir
- Tener presente que muestra adeudos actuales (si existen)

**Importante para Archivo:**
- Este documento es el oficial que se entrega al titular
- Debe firmarse y sellarse
- Se resguarda copia en expediente
- Es la evidencia de la autorización de la licencia
