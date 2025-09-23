# Casos de Prueba para LocalesMtto

## 1. Alta de Local Nuevo
- **Entrada:** Datos completos y válidos de un local inexistente
- **Acción:** Buscar y luego Alta Local
- **Esperado:** Respuesta success true, local creado, adeudos generados

## 2. Alta de Local Existente
- **Entrada:** Datos de un local ya existente
- **Acción:** Buscar
- **Esperado:** Respuesta success true, data.length > 0, frontend bloquea alta

## 3. Validación de Campos Obligatorios
- **Entrada:** Falta campo 'nombre'
- **Acción:** Alta Local
- **Esperado:** Respuesta success false, message 'The nombre field is required.'

## 4. Validación de Giro y Superficie
- **Entrada:** giro = 0 o superficie = 0
- **Acción:** Alta Local
- **Esperado:** Respuesta success false, mensaje de error correspondiente

## 5. Fecha de Alta menor a 2003
- **Entrada:** fecha_alta = '2002-12-31'
- **Acción:** Alta Local
- **Esperado:** Respuesta success false, mensaje de error

## 6. Generación de Adeudos
- **Entrada:** Alta local con fecha_alta = '2024-01-01'
- **Acción:** Alta Local
- **Esperado:** Se generan adeudos desde 2024-01 hasta fecha actual

## 7. Catálogos
- **Entrada:** Cargar página
- **Acción:** loadCatalogs()
- **Esperado:** Se reciben todos los catálogos correctamente
