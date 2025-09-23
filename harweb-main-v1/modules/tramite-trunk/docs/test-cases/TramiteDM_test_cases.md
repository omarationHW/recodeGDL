# Casos de Prueba TramiteDM

## 1. Registro de Adquiriente
- **Entrada**: folio=1001, cvecont=2002, porccoprop=50.0, rfc='XAXX010101000', ...
- **Acción**: saveAdquiriente
- **Esperado**: eResponse.success=true, message='Adquiriente guardado'

## 2. Cálculo de Impuesto
- **Entrada**: folio=1001
- **Acción**: calcImptoTransPat
- **Esperado**: eResponse.success=true, data.total > 0

## 3. Validación de Porcentaje
- **Entrada**: Dos adquirientes, porccoprop=60 y 40
- **Acción**: getPorcentajeTotal
- **Esperado**: eResponse.data.totporc == 100

## 4. Error en Porcentaje
- **Entrada**: Dos adquirientes, porccoprop=60 y 30
- **Acción**: getPorcentajeTotal
- **Esperado**: eResponse.data.totporc == 90, mostrar error en frontend

## 5. Validación de Encabeza
- **Entrada**: Un adquiriente con encabeza='S'
- **Acción**: getEncabeza
- **Esperado**: eResponse.data.encabeza == 'S' o true
