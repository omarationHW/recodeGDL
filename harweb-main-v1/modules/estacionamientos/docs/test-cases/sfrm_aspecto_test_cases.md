# Casos de Prueba: Aspecto Visual

## Caso 1: Cambio exitoso de aspecto
- **Entrada:**
  - operation: setAspecto
  - params: { aspecto: 'SkinDark' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data[0].success = true
  - eResponse.data[0].message = 'Aspecto cambiado correctamente'
  - El aspecto actual se actualiza a 'SkinDark'

## Caso 2: Consulta de aspectos disponibles
- **Entrada:**
  - operation: getAspectos
  - params: {}
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es array con al menos 1 elemento
  - eResponse.data[0].nombre = 'Directorio de Aspectos...'

## Caso 3: Consulta de aspecto actual
- **Entrada:**
  - operation: getCurrentAspecto
  - params: {}
- **Esperado:**
  - eResponse.success = true
  - eResponse.data[0].nombre = 'SkinBlue' (o el valor actual)

## Caso 4: Cambio de aspecto con valor inválido
- **Entrada:**
  - operation: setAspecto
  - params: { aspecto: 'SkinAlien' }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message contiene 'no válido' o error

## Caso 5: Llamada a operación no soportada
- **Entrada:**
  - operation: 'deleteAspecto'
  - params: {}
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'Operación no soportada'
