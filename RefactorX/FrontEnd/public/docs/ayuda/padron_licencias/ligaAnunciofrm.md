# Liga de Anuncios a Licencias

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite asociar (ligar) anuncios publicitarios existentes con licencias o empresas. Es el proceso mediante el cual se establece la relación formal entre un anuncio y el establecimiento comercial que lo utiliza, permitiendo que los adeudos del anuncio se sumen al estado de cuenta de la licencia.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Vincular anuncios con sus licencias correspondientes
- Consolidar adeudos de anuncios en el estado de cuenta de la licencia
- Heredar datos de ubicación de la licencia al anuncio
- Establecer la relación jurídica entre anuncio y establecimiento
- Facilitar el cobro conjunto de licencia y anuncios
- Mantener el control del padrón de anuncios activos

### ¿Quiénes lo utilizan?
- Personal del área de Licencias
- Personal de Anuncios Publicitarios
- Supervisores con autorización
- Personal de cobros que necesita consolidar adeudos

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### Ligar Anuncio a Licencia:
1. Usuario marca checkbox si va a ligar a empresa (no licencia)
2. Ingresa número de licencia o empresa
3. Presiona Enter
4. Sistema valida que exista
5. Si es licencia, verifica inconsistencias:
   - Zona debe estar capturada
   - Subzona debe estar capturada
   - Clave de calle debe existir
   - Ubicación completa
   - Números exterior e interior
   - Letras exterior e interior
6. Si hay inconsistencias, muestra error y no permite continuar
7. Sistema carga y muestra datos de la licencia/empresa:
   - Propietario
   - Domicilio fiscal
   - Ubicación del establecimiento
   - Giro y actividad
8. Usuario ingresa número de anuncio
9. Presiona Enter
10. Sistema valida que el anuncio exista
11. Sistema carga datos del anuncio:
    - Tipo de anuncio
    - Medidas y caras
    - Ubicación actual
    - Estado
12. Verifica vigencia:
    - Anuncio debe estar vigente (V)
    - Licencia/empresa debe estar vigente (V)
13. Si el anuncio ya está ligado:
    - Muestra advertencia
    - Pregunta si desea continuar
14. Usuario confirma la operación
15. Sistema inicia transacción
16. Actualiza tabla anuncios:
    - Asigna id_licencia
    - Si es licencia (no empresa):
      - Hereda zona
      - Hereda subzona
      - Hereda cvecalle
      - Hereda ubicación completa
      - Hereda números exterior e interior
      - Hereda letras exterior e interior
17. Actualiza detsal_lic (detalle de saldos)
18. Ejecuta SP calcSdosLic para recalcular adeudo total
19. Confirma transacción (commit)
20. Muestra mensaje de éxito

### ¿Qué información requiere el usuario?
- **Número de licencia o empresa**: Identificador del establecimiento
- **Número de anuncio**: Identificador del anuncio a ligar
- **Tipo** (checkbox): Si es empresa o licencia

### ¿Qué validaciones se realizan?

#### Validaciones de Existencia:
- La licencia/empresa debe existir
- El anuncio debe existir
- Ambos deben estar en la base de datos

#### Validaciones de Vigencia:
- El anuncio debe estar vigente (vigente='V')
- La licencia/empresa debe estar vigente (vigente='V')
- No se puede ligar a entidades canceladas

#### Validaciones de Consistencia (solo para licencias):
- Zona debe ser > 0
- Subzona debe ser > 0
- Clave de calle (cvecalle) debe ser > 0
- Ubicación no debe ser '0' o vacía
- Número exterior debe estar capturado
- Letra exterior debe estar capturada
- Número interior debe estar capturado
- Letra interior debe estar capturada

#### Validaciones de Negocio:
- Se advierte si el anuncio ya está ligado a otra licencia
- El usuario debe confirmar si desea reasignar
- Las transacciones son atómicas (todo o nada)

### ¿Qué documentos genera?
Este módulo no genera documentos impresos, pero la liga impacta en:
- Estados de cuenta consolidados
- Recibos de pago con anuncios incluidos
- Constancias de licencia con anuncios listados
- Reportes de anuncios por licencia

## Tablas de Base de Datos

### Tabla Principal

**anuncios**: Registro de anuncios publicitarios
- Se actualiza el campo id_licencia para establecer la liga
- Se heredan datos de ubicación de la licencia

**licencias**: Licencias de funcionamiento vigentes
- Se consulta para validar y heredar datos

**empresas**: Empresas registradas (alternativa a licencias)
- Se consulta para ligar anuncios a empresas

### Tablas Relacionadas

#### Tablas que consulta:
- **licencias**: Para validar y obtener datos de ubicación
- **empresas**: Si se está ligando a empresa
- **anuncios**: Para validar y actualizar
- **detsal_lic**: Para actualizar saldos
- **c_tipoanuncio**: Para mostrar tipo de anuncio

#### Tablas que modifica:
- **anuncios**:
  - UPDATE: Asigna id_licencia
  - UPDATE: Hereda ubicación de licencia (zona, subzona, calle, números, letras)
- **detsal_lic**:
  - UPDATE: Asocia adeudos del anuncio con la licencia
- **saldos_lic** (indirectamente a través del SP):
  - Recalcula adeudo total incluyendo el anuncio

## Stored Procedures

### calcSdosLic
**Propósito**: Recalcula todos los adeudos de la licencia incluyendo sus anuncios ligados
**Parámetros**:
- `id_licencia`: Identificador de la licencia
**Descripción**:
- Suma derechos de la licencia
- Suma derechos de todos los anuncios ligados
- Calcula recargos
- Calcula formas
- Actualiza saldo total

## Impacto y Repercusiones

### ¿Qué registros afecta?
- **Registro del anuncio**: Se actualiza con id_licencia y ubicación
- **Detalle de saldos**: Se asocian los adeudos del anuncio
- **Saldos de licencia**: Se recalcula el adeudo total
- **Estado de cuenta**: El anuncio aparece en el estado de cuenta de la licencia

### ¿Qué cambios de estado provoca?
- El anuncio queda ligado a la licencia
- Los adeudos del anuncio se suman al estado de cuenta de la licencia
- La ubicación del anuncio se sincroniza con la licencia
- El anuncio hereda datos catastrales de la licencia

### ¿Qué documentos/reportes genera?
Indirectamente, la liga afecta:
- Estados de cuenta que incluyen el anuncio
- Recibos de pago consolidados
- Listados de anuncios por licencia
- Reportes de adeudos totales
- Constancias de licencia con anuncios

### ¿Qué validaciones de negocio aplica?
- **Vigencia obligatoria**: Ambos deben estar vigentes
- **Consistencia de datos**: La licencia debe tener ubicación completa
- **Advertencia de reasignación**: Si el anuncio ya está ligado
- **Transaccionalidad**: Cambios atómicos con rollback en caso de error
- **Integridad**: No se permite ligar a licencias inconsistentes

## Flujo de Trabajo

### Flujo de Liga de Anuncio

```
1. Inicio
2. ¿Es empresa o licencia?
   - Usuario marca/desmarca checkbox
3. Usuario ingresa número de licencia/empresa
4. Presiona Enter
5. ¿Existe licencia/empresa?
   - No: Mostrar error y terminar
   - Sí: Continuar
6. Sistema carga datos en pantalla
7. ¿Es licencia?
   - Sí: Validar inconsistencias
     a. ¿Zona = 0?
     b. ¿Subzona = 0?
     c. ¿Cvecalle = 0?
     d. ¿Ubicación = 0?
     e. ¿Número exterior = 0?
     f. ¿Letra exterior = 0?
     g. ¿Número interior = 0?
     h. ¿Letra interior = 0?
     - Si alguna validación falla:
       * Agregar a lista de inconsistencias
       * Mostrar mensaje con todas las inconsistencias
       * Terminar sin permitir continuar
   - No (es empresa): Continuar sin validaciones
8. Usuario ingresa número de anuncio
9. Presiona Enter
10. ¿Existe anuncio?
    - No: Mostrar error y terminar
    - Sí: Continuar
11. Sistema carga datos del anuncio
12. Sistema carga tipo de anuncio
13. Habilita botón Aceptar
14. Usuario presiona "Aceptar"
15. ¿Anuncio vigente?
    - No: Mostrar error "No se puede ligar anuncio cancelado"
    - Sí: Continuar
16. ¿Licencia/empresa vigente?
    - No: Mostrar error
    - Sí: Continuar
17. ¿Anuncio ya tiene id_licencia > 0?
    - Sí:
      * Mostrar mensaje "Ya está ligado, ¿Continuar?"
      * ¿Usuario confirma?
        - No: Cancelar y terminar
        - Sí: Continuar
    - No: Continuar
18. Iniciar transacción
19. Cerrar query de actualización
20. Construir SQL UPDATE para tabla anuncios
21. ¿Es empresa?
    - Sí:
      * UPDATE anuncios SET id_licencia = {id_licencia_empresa}
      * WHERE id_anuncio = {id_anuncio}
    - No (es licencia):
      * UPDATE anuncios SET
        - id_licencia = {id_licencia}
        - zona = {zona_licencia}
        - subzona = {subzona_licencia}
        - cvecalle = {cvecalle_licencia}
        - ubicacion = {ubicacion_licencia}
        - numext_ubic = {numext_licencia}
        - letraext_ubic = {letraext_licencia}
        - numint_ubic = {numint_licencia}
        - letraint_ubic = {letraint_licencia}
      * WHERE id_anuncio = {id_anuncio}
22. Ejecutar UPDATE
23. Actualizar detalle de saldo:
    - UpdDetsalLic con id_licencia y id_anuncio
24. Ejecutar SP calcSdosLic(id_licencia)
25. ¿Transacción exitosa?
    - No:
      * Rollback
      * Mostrar error
      * Terminar
    - Sí:
      * Commit
      * Deshabilitar botón Aceptar
      * Continuar
26. Mostrar mensaje de éxito
27. Fin
```

## Notas Importantes

### Consideraciones especiales

#### Diferencia Licencia vs Empresa:
- **Licencia**: Hereda ubicación completa al anuncio
- **Empresa**: Solo se liga, no hereda ubicación
- Las licencias tienen validaciones estrictas de ubicación
- Las empresas no requieren esas validaciones

#### Heredar Ubicación:
Cuando se liga a licencia, el anuncio recibe:
- Zona catastral
- Subzona catastral
- Clave de calle
- Nombre de ubicación
- Números exterior e interior
- Letras exterior e interior

Esto garantiza que el anuncio tenga la misma dirección que la licencia.

#### Consistencia de Datos:
Las licencias deben tener datos completos de ubicación:
- Si faltan datos, el sistema no permite ligar
- Esto evita inconsistencias en el padrón
- Se debe corregir la licencia primero (usar modlicfrm)

#### Reasignación de Anuncios:
- Un anuncio puede estar ligado a una licencia
- Si se intenta ligar a otra licencia:
  - El sistema advierte
  - El usuario debe confirmar
  - Se reasigna a la nueva licencia
  - Los adeudos se transfieren

### Restricciones
- No se puede ligar a licencias/empresas canceladas
- No se puede ligar anuncios cancelados
- La licencia debe tener ubicación completa y válida
- Solo un anuncio puede estar activo en una ubicación
- La transacción debe completarse exitosamente

### Permisos necesarios
- Acceso al formulario de liga de anuncios
- Permisos para modificar anuncios
- Autorización para consolidar adeudos

### Mejores prácticas de uso
1. **Verificación previa**: Confirmar que licencia y anuncio coinciden
2. **Validar ubicación**: Asegurar que la licencia tenga datos completos
3. **Revisar vigencia**: Ambos deben estar vigentes
4. **Confirmar datos**: Verificar que la información cargada sea correcta
5. **Reasignación**: Si el anuncio ya está ligado, verificar el motivo
6. **Estado de cuenta**: Revisar el nuevo adeudo consolidado después de ligar
7. **Documentación**: Anotar la liga en expedientes físicos
8. **Comunicación**: Notificar al contribuyente del nuevo estado de cuenta
9. **Coordinación**: Informar al área de cobros sobre cambios en adeudos
10. **Verificación final**: Consultar el estado de cuenta para confirmar la liga

### Casos especiales

#### Anuncio sin ubicación previa:
- Al ligarse, hereda toda la ubicación de la licencia
- Simplifica la captura de datos

#### Cambio de titular:
- Si cambia el titular de la licencia, el anuncio se mantiene ligado
- No requiere un proceso de re-liga

#### Licencia con múltiples anuncios:
- Una licencia puede tener varios anuncios ligados
- Todos se suman al estado de cuenta
- Se manejan individualmente en el detalle

#### Desligar anuncio:
- Este módulo no desliga anuncios
- Para desligar, usar módulo de modificación de anuncios
- Establecer id_licencia = NULL o 0

### Impacto en otros módulos

Esta operación afecta a:
- **Consulta de licencias**: Muestra anuncios ligados
- **Consulta de anuncios**: Muestra licencia asociada
- **Generación de adeudos**: Calcula total consolidado
- **Cobro**: Permite pagar licencia y anuncios juntos
- **Estados de cuenta**: Incluye adeudo de anuncios
- **Reportes**: Estadísticas de anuncios por licencia

### Transaccionalidad
- La operación es transaccional
- Si falla cualquier paso, se hace rollback
- No se guardan cambios parciales
- Garantiza integridad de datos
- Previene inconsistencias en el padrón

### Auditoría
- Aunque no se registra explícitamente, los cambios son rastreables:
  - Fecha de actualización en tabla anuncios
  - Cambio de id_licencia registrado
  - Recálculo de saldos documentado
- Importante para aclaraciones o disputas
