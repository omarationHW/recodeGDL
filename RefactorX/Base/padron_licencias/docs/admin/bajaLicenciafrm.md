# Baja/Cancelación de Licencias y Anuncios

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite dar de baja (cancelar) licencias de funcionamiento y anuncios publicitarios. Es una operación administrativa crítica que registra formalmente el cese de operaciones de un establecimiento o la cancelación de un anuncio, generando el folio oficial de baja.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Formalizar el cierre definitivo de establecimientos comerciales
- Cancelar anuncios que ya no están en operación
- Generar el folio oficial de baja para efectos administrativos y legales
- Registrar la fecha y motivo de cancelación
- Actualizar el estado de vigencia de licencias y anuncios
- Mantener el control del padrón de contribuyentes activos

### ¿Quiénes lo utilizan?
- Personal autorizado del área de Licencias
- Supervisores con permisos especiales
- Personal administrativo con nivel suficiente
- Usuarios con autorización para realizar bajas definitivas

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### Baja de Licencia:
1. Usuario selecciona "Licencia" en el RadioGroup
2. Ingresa el número de licencia a dar de baja
3. Hace clic en "Buscar"
4. El sistema valida que la licencia exista
5. Se verifica el estado actual:
   - Debe estar vigente (V) para poder dar de baja
   - Si ya está cancelada, muestra error
6. Sistema carga todos los datos de la licencia
7. Sistema muestra el adeudo actual si existe
8. Usuario verifica la información
9. Sistema solicita firma electrónica para autorizar la baja
10. Se valida la firma y permisos
11. Sistema genera el folio consecutivo de baja (del año actual)
12. Se actualiza el registro:
    - vigente = 'B' (Baja)
    - fecha_baja = fecha actual
    - axo_baja = año actual
    - folio_baja = folio consecutivo generado
13. Sistema muestra el folio de baja asignado
14. Se registra en el historial (h_lic)

#### Baja de Anuncio:
1. Usuario selecciona "Anuncio" en el RadioGroup
2. Ingresa el número de anuncio
3. Hace clic en "Buscar"
4. Sistema valida que el anuncio exista y esté vigente
5. Sistema carga datos del anuncio
6. Usuario verifica información
7. Sistema solicita firma electrónica
8. Se valida autorización
9. Sistema genera folio de baja consecutivo
10. Se actualiza:
    - vigente = 'B'
    - fecha_baja, axo_baja, folio_baja
11. Se muestra folio asignado
12. Se registra en historial (h_anun)

### ¿Qué información requiere el usuario?
- **Número de licencia o anuncio**: Identificador del registro a dar de baja
- **Firma electrónica**: Contraseña de autorización del usuario
- **Motivo** (implícito): La operación de baja por sí misma documenta la cancelación

### ¿Qué validaciones se realizan?
- **Existencia**: La licencia/anuncio debe existir en la base de datos
- **Vigencia**: Solo se pueden dar de baja registros vigentes (vigente='V')
- **No se puede dar de baja**:
  - Licencias/anuncios ya cancelados
  - Licencias/anuncios con estado diferente a 'V'
- **Autorización**: Se requiere firma electrónica válida
- **Permisos**: El usuario debe tener nivel suficiente
- **Folio**: Se valida que el año del folio sea el actual

### ¿Qué documentos genera?
- **Folio de baja**: Número consecutivo oficial de cancelación
- Aunque no imprime físicamente, el folio generado es utilizado en:
  - Oficios de baja
  - Constancias de cancelación
  - Reportes de licencias canceladas
  - Expedientes administrativos

## Tablas de Base de Datos

### Tabla Principal
**licencias**: Registro de licencias de funcionamiento
- Se modifica el estado de vigencia y se asigna folio de baja

**anuncios**: Registro de anuncios publicitarios
- Se modifica el estado y se asigna folio de baja

### Tablas Relacionadas

#### Tablas que consulta:
- **licencias**: Para cargar datos de la licencia a dar de baja
- **anuncios**: Para cargar datos del anuncio
- **folios**: Para obtener el siguiente folio consecutivo de baja
- **saldos_lic**: Para mostrar el adeudo actual

#### Tablas que modifica:
- **licencias**:
  - UPDATE: Cambia vigente='B', fecha_baja, axo_baja, folio_baja
- **anuncios**:
  - UPDATE: Cambia vigente='B', fecha_baja, axo_baja, folio_baja
- **folios**:
  - UPDATE: Incrementa el contador de folios de baja del año
- **h_lic** (historial):
  - INSERT/UPDATE: Registra el cambio en el historial
- **h_anun** (historial):
  - INSERT/UPDATE: Registra el cambio

## Stored Procedures

### verifica_firma
**Propósito**: Valida la firma electrónica del usuario para autorizar la baja
**Parámetros**:
- `p_usuario`: Usuario del sistema
- `p_login`: Login (puede ir vacío)
- `p_firma`: Contraseña/firma a validar
- `p_modulos_id`: ID del módulo (para bajas)
**Descripción**: Verifica que el usuario tenga permisos para realizar bajas y que la contraseña sea correcta.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- **Registro principal**: Licencia o anuncio que se da de baja
- **Contador de folios**: Se incrementa el folio consecutivo del año
- **Historial**: Se registra el cambio en tablas h_lic o h_anun
- **Saldos**: Los adeudos se mantienen pero la licencia ya no está vigente

### ¿Qué cambios de estado provoca?
- **Estado de vigencia**: Cambia de 'V' (Vigente) a 'B' (Baja)
- **Asignación de folio**: Se genera y asigna folio oficial de baja
- **Fecha de baja**: Se registra la fecha en que se realiza la cancelación
- **Inoperancia**: La licencia/anuncio ya no puede usarse para trámites
- **Padrón**: Sale del padrón de contribuyentes activos

### ¿Qué documentos/reportes genera?
Indirectamente, la información es utilizada en:
- Oficios de cancelación
- Constancias de baja
- Reportes de licencias canceladas por periodo
- Estadísticas de altas y bajas
- Auditorías administrativas
- Expedientes de archivo

### ¿Qué validaciones de negocio aplica?
- **Irreversibilidad**: Una vez dada de baja, no puede reactivarse desde este módulo
- **Folio único**: Cada baja tiene un folio consecutivo único del año
- **Adeudos**: Aunque se da de baja, los adeudos previos se mantienen
- **Trazabilidad**: Se registra fecha exacta y usuario que realizó la baja
- **Autorización**: Requiere firma electrónica obligatoria

## Flujo de Trabajo

### Flujo de Baja de Licencia

```
1. Inicio
2. Usuario selecciona "Licencia"
3. Ingresa número de licencia
4. Presiona "Buscar"
5. ¿Licencia existe?
   - No: Mostrar error y terminar
   - Sí: Continuar
6. Sistema carga datos de la licencia
7. ¿Licencia está vigente (V)?
   - No: Mostrar error "Ya está cancelada" y terminar
   - Sí: Continuar
8. Sistema consulta adeudo actual
9. Muestra datos completos en pantalla
10. Usuario revisa información
11. Usuario presiona "Dar de Baja"
12. Sistema solicita firma electrónica
13. ¿Firma válida?
    - No: Mostrar error y cancelar
    - Sí: Continuar
14. Sistema inicia transacción
15. Sistema consulta último folio de baja del año actual
16. Sistema calcula nuevo folio = folio_actual + 1
17. Sistema actualiza tabla licencias:
    - vigente = 'B'
    - fecha_baja = fecha actual
    - axo_baja = año actual
    - folio_baja = nuevo folio
18. Sistema actualiza contador de folios
19. ¿Asiento = 1?
    - Sí: Actualizar tabla h_lic, cambiar asiento a 0
    - No: Continuar
20. Sistema confirma transacción (commit)
21. Muestra mensaje: "Baja realizada. Folio: XXXX/20XX"
22. Limpia formulario
23. Fin
```

### Flujo de Baja de Anuncio

```
1. Inicio
2. Usuario selecciona "Anuncio"
3. Ingresa número de anuncio
4. Presiona "Buscar"
5. ¿Anuncio existe?
   - No: Mostrar error y terminar
   - Sí: Continuar
6. Sistema carga datos del anuncio
7. ¿Anuncio está vigente (V)?
   - No: Mostrar error y terminar
   - Sí: Continuar
8. Muestra datos en pantalla
9. Usuario presiona "Dar de Baja"
10. Sistema solicita firma electrónica
11. ¿Firma válida?
    - No: Cancelar operación
    - Sí: Continuar
12. Sistema obtiene siguiente folio de baja
13. Sistema actualiza tabla anuncios:
    - vigente = 'B'
    - fecha_baja = fecha actual
    - axo_baja = año actual
    - folio_baja = folio generado
14. Actualiza contador de folios
15. Actualiza historial (h_anun)
16. Muestra folio asignado
17. Limpia formulario
18. Fin
```

## Notas Importantes

### Consideraciones especiales
- **Operación irreversible**: La baja desde este módulo es definitiva
- **Folio consecutivo**: Se genera automáticamente, no puede modificarse
- **Adeudos persisten**: Los adeudos anteriores a la baja se mantienen
- **Firma obligatoria**: No se puede dar de baja sin autorización
- **Control de folios**: Los folios son por año, se reinician cada enero

### Restricciones
- Solo se pueden dar de baja licencias/anuncios vigentes
- No se puede modificar el folio una vez asignado
- No se puede reactivar desde este módulo (requiere otro proceso)
- El folio no puede ser menor o igual al último asignado
- La fecha de baja siempre es la fecha actual del sistema

### Permisos necesarios
- **Firma electrónica válida**: Obligatoria para cualquier baja
- **Nivel de usuario**: Debe tener permisos para módulo de bajas
- **Acceso al formulario**: Controlado por permisos del menú
- **Auditoría**: Todas las bajas son auditables

### Mejores prácticas de uso
1. **Verificación**: Confirmar que es la licencia/anuncio correcto antes de proceder
2. **Adeudos**: Revisar si hay adeudos pendientes antes de dar de baja
3. **Documentación**: Tener la documentación de respaldo (solicitud del contribuyente, acta, etc.)
4. **Registro físico**: Anotar el folio de baja en el expediente físico
5. **Notificación**: Informar al contribuyente del folio de baja asignado
6. **Coordinación**: Notificar a otras áreas (cobros, inspección) sobre la baja
7. **Archivo**: Guardar copia del folio en el expediente del contribuyente

### Diferencia entre tipos de cancelación
- **'B' (Baja)**: Cancelación definitiva por solicitud o por oficio
- **'C' (Cancelado)**: Otro tipo de cancelación (puede variar según municipio)
- **'V' (Vigente)**: Estado activo, operando normalmente
- **'A' (Estado 1)**: Suspensión temporal (según configuración local)

### Casos especiales
- **Baja con adeudo**: Se permite dar de baja aunque tenga deuda
- **Baja sin solicitud**: Puede requerirse proceso especial de notificación
- **Baja por clausura**: Puede requerir documentación de inspección
- **Baja por cambio de domicilio**: Requiere dar de baja y generar nueva solicitud
- **Baja de anuncio independiente**: Se puede dar de baja anuncio sin afectar licencia

### Impacto en otros módulos
Esta operación afecta a:
- **Consulta de licencias**: Ya no aparecerá como vigente
- **Generación de adeudos**: No se generarán nuevos adeudos anuales
- **Reportes**: Aparecerá en reportes de licencias canceladas
- **Cobro**: Los adeudos anteriores siguen cobrables
- **Inspección**: Ya no puede ser sujeto de inspección regular
- **Renovación**: No se puede renovar una licencia dada de baja

### Reactivación posterior
Si se requiere reactivar una licencia/anuncio dado de baja:
1. No se puede hacer desde este módulo
2. Se requiere usar el módulo de "Modificación de licencias"
3. Necesita autorización especial
4. Se recalculan adeudos desde el año de baja
5. Se mantiene el folio de baja en el historial

### Control de folios
- Los folios son consecutivos por año
- Formato típico: XXXX/20YY (ej: 0001/2024)
- Se reinician el 1 de enero de cada año
- No pueden repetirse dentro del mismo año
- Se guardan en tabla específica de control de folios
