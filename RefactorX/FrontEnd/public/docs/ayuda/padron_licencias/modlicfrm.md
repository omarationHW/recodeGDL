# Modificación de Licencias y Anuncios

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite modificar la información de licencias de funcionamiento y anuncios publicitarios ya otorgados. Es uno de los módulos más importantes del sistema ya que permite corregir datos, actualizar información del contribuyente, cambiar giros, modificar ubicaciones y gestionar toda la información relacionada con licencias y anuncios vigentes.

### ¿Para qué sirve en el proceso administrativo?
Sirve para mantener actualizada la información de licencias y anuncios cuando:
- Hay cambios en los datos del propietario
- Se requiere corregir errores en la captura original
- Cambia la ubicación del establecimiento
- Se modifica el giro o actividad económica
- Se actualizan datos catastrales o de ubicación geográfica
- Se reactivan licencias o anuncios cancelados
- Se actualizan adeudos y se recalculan saldos

### ¿Quiénes lo utilizan?
- Personal del área de Licencias y Funcionamiento
- Personal de ventanilla con permisos especiales
- Supervisores del área de Catastro
- Administradores del sistema
- Personal autorizado con firma electrónica

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### Modificación de Licencia:
1. Usuario selecciona "Licencia" en el RadioGroup
2. Ingresa el número de licencia a modificar
3. Hace clic en "Buscar"
4. El sistema valida que la licencia exista
5. Se cargan todos los datos de la licencia en pantalla:
   - Datos del propietario
   - Ubicación del establecimiento
   - Giro y actividad
   - Datos de construcción
   - Historial y saldos
6. Usuario modifica los campos necesarios
7. Puede actualizar:
   - Giro/Actividad (con búsqueda SCIAN)
   - Datos del propietario (nombre, RFC, CURP)
   - Domicilio fiscal
   - Ubicación del negocio
   - Datos de construcción (superficie, cajones, empleados)
   - Coordenadas geográficas (desde mapa)
8. Sistema solicita firma electrónica para autorizar cambios
9. Se valida la firma contra el stored procedure `verifica_firma`
10. Sistema actualiza el registro de la licencia
11. Si es reactivación, se generan nuevos saldos desde el último año pagado
12. Se recalcula el adeudo usando el SP `calcSdosLic`
13. Se actualiza la tabla de saldos

#### Modificación de Anuncio:
1. Usuario selecciona "Anuncio" en el RadioGroup
2. Ingresa el número de anuncio
3. Hace clic en "Buscar"
4. Sistema carga datos del anuncio:
   - Tipo de anuncio
   - Medidas y número de caras
   - Ubicación
   - Datos del fabricante
5. Usuario modifica campos necesarios
6. Sistema solicita firma electrónica
7. Se actualizan datos del anuncio
8. Se recalcula el saldo según:
   - Superficie del anuncio (medida1 × medida2 × caras)
   - Valores vigentes del año
   - Descuentos por cuatrimestre si aplica
9. Se actualiza el adeudo de la licencia asociada

### ¿Qué información requiere el usuario?

#### Para Licencia:
**Datos del Propietario:**
- Primer apellido
- Segundo apellido
- Nombre(s)
- RFC
- CURP
- Teléfono
- Email

**Ubicación del Negocio:**
- Calle (con búsqueda)
- Número exterior y letra
- Número interior y letra
- Colonia (con búsqueda)
- Código Postal
- Zona y subzona
- Coordenadas (opcional, desde mapa)

**Datos del Establecimiento:**
- Giro SCIAN (con búsqueda)
- Actividad específica (con búsqueda)
- Superficie construida
- Superficie autorizada
- Número de cajones de estacionamiento
- Número de empleados
- Aforo
- Inversión
- Horario

#### Para Anuncio:
- Tipo de anuncio (giro)
- Medidas (alto × ancho)
- Número de caras
- Ubicación (heredada de licencia asociada)
- Texto del anuncio
- Fabricante

### ¿Qué validaciones se realizan?

#### Validaciones de Negocio:
- La licencia/anuncio debe existir
- No se puede modificar si está bloqueada (valores 1-4)
- Para reactivar se requiere autorización especial
- Los giros y actividades deben estar vigentes
- Las calles y colonias deben existir en el catálogo
- El RFC debe tener formato válido
- El CURP debe tener formato válido

#### Validaciones de Seguridad:
- Requiere firma electrónica para confirmar cambios
- La firma se valida contra la tabla de usuarios autorizados
- Se valida el módulo específico (id_modulo = 1 para licencias)
- Para ubicación en mapa se requiere firma especial (id_modulo = 2)

#### Validaciones de Datos:
- Los campos numéricos deben ser válidos
- Las fechas deben estar en formato correcto
- El cálculo del área del anuncio debe ser correcto
- Los saldos se recalculan automáticamente

### ¿Qué documentos genera?
Este módulo no genera documentos impresos directamente, pero las modificaciones impactan en:
- Estados de cuenta actualizados
- Constancias de licencia con datos nuevos
- Recibos de pago con información actualizada
- Reportes de licencias vigentes

## Tablas de Base de Datos

### Tabla Principal

**licencias**: Almacena la información completa de cada licencia
- Datos del propietario
- Ubicación del establecimiento
- Giro y actividad
- Datos de construcción
- Estado y vigencia
- Coordenadas geográficas

**anuncios**: Almacena la información de anuncios publicitarios
- Referencia a la licencia asociada
- Tipo de anuncio
- Medidas y especificaciones
- Ubicación
- Estado y vigencia

### Tablas Relacionadas

#### Tablas que consulta:
- **c_callesQry**: Catálogo de calles para validar ubicaciones
- **c_giros**: Catálogo de giros SCIAN
- **c_scian_qry**: Catálogo del Sistema de Clasificación Industrial
- **giros_nvo_qry**: Actividades específicas por giro
- **c_valoreslic**: Valores vigentes de derechos por año y giro
- **parametros_lic**: Parámetros del sistema (formas, valores, etc.)
- **h_lic**: Historial de cambios en licencias
- **h_anun**: Historial de cambios en anuncios

#### Tablas que modifica:
- **licencias**: UPDATE de todos los campos modificados
- **anuncios**: UPDATE de datos del anuncio
- **saldos_lic**: INSERT si no existe, recálculo de adeudos
- **detsal_lic**: UPDATE de saldos por año
- **h_lic**: INSERT/UPDATE para mantener historial
- **h_anun**: INSERT/UPDATE para mantener historial
- **lic_ubic**: INSERT de coordenadas geográficas
- **crucecalles**: UPDATE de cruces de calles

## Stored Procedures

### calcSdosLic
**Propósito**: Recalcula todos los adeudos de una licencia
**Parámetros**:
- `id_licencia`: Identificador de la licencia
**Descripción**: Este SP recalcula los derechos, recargos, formas y total del adeudo de la licencia, considerando:
- Años pendientes de pago
- Valores vigentes por año
- Descuentos aplicables
- Recargos por mora
- Suma de adeudos de anuncios asociados

### verifica_firma
**Propósito**: Valida la firma electrónica del usuario
**Parámetros**:
- `p_usuario`: Usuario del sistema
- `p_login`: Login (puede ir vacío)
- `p_firma`: Firma/contraseña a validar
- `p_modulos_id`: ID del módulo (1=licencias, 2=ubicación)
**Descripción**: Verifica que el usuario tenga permisos para realizar la operación y que la firma sea correcta.

### get_sess
**Propósito**: Obtiene el ID de sesión para ubicación en mapa
**Descripción**: Genera o recupera un identificador de sesión único para el proceso de captura de coordenadas desde el mapa web.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- **Registro de la licencia/anuncio modificado**: Actualización directa
- **Historial de cambios**: Se registra cada modificación
- **Saldos y adeudos**: Se recalculan automáticamente
- **Cuenta predial asociada**: Si hay cambios en ubicación
- **Anuncios ligados** (en caso de modificar licencia): Heredan cambios de ubicación

### ¿Qué cambios de estado provoca?
- **Reactivación**: Cambia vigente de 'B' o 'C' a 'V'
- **Actualización de asiento**: Si asiento=1 se cambia a 0 en tabla actual e historial
- **Generación de adeudos**: Si es reactivación, genera saldos desde último año pagado
- **Actualización de ubicación**: Cambia nombre de calle si se modifica cvecalle
- **Cambio de giro**: Actualiza id_giro y descripción de actividad

### ¿Qué documentos/reportes genera?
Indirectamente, las modificaciones se reflejan en:
- Extractos de adeudo actualizados
- Constancias de licencia con información nueva
- Listados de licencias vigentes
- Reportes de recaudación
- Bitácora de cambios (auditoría)

### ¿Qué validaciones de negocio aplica?
- **Existencia**: La licencia/anuncio debe existir
- **Vigencia**: Permite modificar canceladas solo si se reactivan explícitamente
- **Bloqueo**: No permite modificar si está bloqueada (excepto niveles específicos)
- **Asiento**: Controla que no se generen duplicados en historial
- **Cálculos**: Valida que los cálculos de superficie de anuncio sean correctos
- **Integridad referencial**: Valida existencia de giros, calles, colonias
- **Autorización**: Requiere firma electrónica para confirmar cambios

## Flujo de Trabajo

### Flujo de Modificación de Licencia

```
1. Inicio
2. Usuario selecciona "Licencia"
3. Ingresa número de licencia
4. Presiona "Buscar"
5. ¿Existe la licencia?
   - No: Mostrar error y volver a paso 3
   - Sí: Continuar
6. Sistema carga todos los datos en pantalla
7. Sistema carga giro SCIAN y actividades asociadas
8. ¿Licencia cancelada?
   - Sí: Mostrar panel de reactivación
   - No: Continuar
9. Usuario modifica campos necesarios
10. ¿Usuario modificó giro/actividad?
    - Sí: Sistema valida que seleccione del catálogo
    - No: Continuar
11. Usuario presiona "Actualizar"
12. Sistema solicita firma electrónica
13. ¿Firma válida?
    - No: Mostrar error y cancelar
    - Sí: Continuar
14. ¿Es reactivación?
    - Sí: Cambiar vigente='V', limpiar fecha_baja
    - No: Continuar
15. Actualizar registro en tabla licencias
16. ¿Existe registro en saldos_lic?
    - No: Crear registro base
    - Sí: Continuar
17. Ejecutar SP calcSdosLic para recalcular adeudo
18. Actualizar tabla h_lic si asiento=1
19. Actualizar nombre de calle si cambió cvecalle
20. Mostrar mensaje de confirmación
21. Fin
```

### Flujo de Modificación de Anuncio

```
1. Inicio
2. Usuario selecciona "Anuncio"
3. Ingresa número de anuncio
4. Presiona "Buscar"
5. ¿Existe el anuncio?
   - No: Mostrar error y volver a paso 3
   - Sí: Continuar
6. Sistema carga datos del anuncio y detalle de saldo
7. ¿Anuncio cancelado?
   - Sí: Mostrar panel de reactivación
   - No: Continuar
8. Usuario modifica campos
9. Usuario presiona "Actualizar"
10. Sistema solicita firma electrónica
11. ¿Firma válida?
    - No: Mostrar error y cancelar
    - Sí: Continuar
12. ¿Es reactivación?
    - Sí: Cambiar vigente='V'
    - No: Continuar
13. Actualizar registro en tabla anuncios
14. Calcular superficie = medidas1 × medidas2 × num_caras
15. Para cada año en detsal_lic:
    a. Obtener valores vigentes del año
    b. Calcular monto = costo × superficie
    c. ¿Es año de otorgamiento?
       - Sí: Aplicar descuento por cuatrimestre
       - No: Continuar
    d. Actualizar derechos, forma y saldo
16. Ejecutar SP calcSdosLic de la licencia asociada
17. Actualizar tabla h_anun si asiento=1
18. Fin
```

### Flujo de Ubicación en Mapa

```
1. Usuario presiona botón "Mapa"
2. Sistema solicita firma con privilegios especiales
3. ¿Firma válida para módulo 2?
   - No: Mostrar error y cancelar
   - Sí: Continuar
4. Sistema obtiene ID de sesión (get_sess)
5. Sistema limpia ubicaciones previas de la sesión
6. Sistema abre navegador con URL del mapa + sesión ID
7. Usuario selecciona ubicación en el mapa web
8. Sistema externo guarda coordenadas en lic_ubicses
9. Sistema monitorea tabla cada segundo (Timer)
10. ¿Se registró ubicación?
    - No: Continuar monitoreando
    - Sí: Continuar
11. Sistema muestra checkbox marcado
12. Usuario presiona botón para confirmar ubicación
13. Sistema inserta coordenadas en lic_ubic para la licencia
14. Sistema limpia datos de sesión
15. Mostrar mensaje de confirmación
16. Fin
```

## Notas Importantes

### Consideraciones especiales

#### Cambio de Giro/Actividad:
- A partir de 2023 se implementó el nuevo sistema de actividades
- Primero se selecciona el giro SCIAN (código general)
- Luego se selecciona la actividad específica dentro del giro
- El sistema valida que la actividad seleccionada corresponda al giro
- Las actividades tienen código >= 5000 en la tabla c_giros

#### Reactivación de Licencias:
- Requiere autorización especial
- Se limpian las fechas de baja
- Se generan adeudos desde el último año pagado
- No se pueden reactivar licencias bloqueadas (excepto bloqueo tipo 5)

#### Asientos:
- El campo "asiento" controla que no se dupliquen registros en el historial
- Si asiento=1, se cambia a 0 en la tabla actual y en h_lic/h_anun

#### Cálculo de Superficie de Anuncios:
- Superficie = Medida1 × Medida2 × NumCaras
- Se redondea siempre hacia arriba
- Si superficie < 1, se considera 1
- Los valores menores se convierten en 1 metro cuadrado

#### Descuentos por Cuatrimestre (Anuncios):
- Si es el mismo año de otorgamiento:
  - Cuatrimestre 1 (ene-abr): 100% del costo
  - Cuatrimestre 2 (may-ago): 70% del costo
  - Cuatrimestre 3 (sep-dic): 30% del costo

### Restricciones

- No se puede modificar una licencia/anuncio que no existe
- No se puede modificar si está bloqueada (valores 1-4)
- Para cambiar giro se requiere que existan actividades registradas
- La firma electrónica es obligatoria para cualquier modificación
- No se puede seleccionar una actividad que no esté en el catálogo
- La reactivación tiene validaciones especiales de adeudos
- Solo se puede ubicar en mapa si es tipo licencia (no anuncio)

### Permisos necesarios

#### Para modificaciones normales:
- Firma electrónica válida
- Permiso de módulo 1 (licencias)
- Acceso al formulario de modificación

#### Para reactivación:
- Firma electrónica con nivel especial
- Autorización para reactivar licencias/anuncios

#### Para ubicación en mapa:
- Firma electrónica con permisos especiales
- Permiso de módulo 2 (ubicación)
- Usuario específico con privilegios geográficos

#### Para modificar adeudos manualmente:
- Nivel de usuario = 1 (administrador)
- Firma electrónica válida

### Mejores prácticas de uso

1. **Verificación previa**: Siempre verificar los datos antes de modificar
2. **Copia de respaldo**: Consultar el historial antes de cambios mayores
3. **Validación de datos**: Asegurar que RFC, CURP sean válidos
4. **Cambio de giro**: Verificar que la nueva actividad sea la correcta
5. **Reactivaciones**: Verificar adeudos antes de reactivar
6. **Ubicación**: Validar en mapa que sea la ubicación correcta
7. **Documentación**: Usar el campo de observaciones para justificar cambios
8. **Recálculo de adeudos**: Esperar a que termine antes de hacer más cambios
9. **Coordenadas**: Verificar que las coordenadas sean precisas antes de confirmar
10. **Firma electrónica**: No compartir credenciales, cada usuario usa la suya

### Impacto en otros módulos

Este módulo afecta a:
- **Consulta de licencias**: Muestra datos actualizados
- **Generación de adeudos**: Usa los saldos recalculados
- **Emisión de constancias**: Imprime información modificada
- **Reportes**: Reflejan cambios en estadísticas
- **Cobro**: Utiliza los adeudos recalculados
- **Ventanilla**: Consulta información actualizada
- **Anuncios ligados**: Heredan cambios de ubicación de la licencia

### Mantenimiento y auditoría

- Todos los cambios quedan registrados en h_lic y h_anun
- Se registra usuario y fecha de modificación
- Los cambios de giro son críticos y deben auditarse
- Las reactivaciones deben revisarse periódicamente
- Verificar que los cálculos de adeudos sean correctos
- Revisar cambios masivos de ubicación
- Auditar uso de firmas electrónicas
- Monitorear reactivaciones frecuentes (posible fraude)
