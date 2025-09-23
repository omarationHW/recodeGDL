# Casos de Prueba PasoAdeudos

## 1. Generación y Previsualización de Adeudos
- **Entrada:** año=2024, trimestre=1
- **Acción:** POST /api/execute { action: 'generarAdeudos', params: { ano: 2024, trimestre: 1 } }
- **Esperado:** Respuesta success=true, data contiene lista de adeudos con campos correctos.

## 2. Inserción Correcta de Adeudos
- **Entrada:** Lista de adeudos generados
- **Acción:** POST /api/execute { action: 'insertarAdeudos', params: { adeudos: [...] } }
- **Esperado:** Respuesta success=true, data.insertados = cantidad de adeudos insertados.

## 3. Prevención de Duplicados
- **Entrada:** Lista de adeudos ya existentes
- **Acción:** POST /api/execute { action: 'insertarAdeudos', params: { adeudos: [...] } }
- **Esperado:** Respuesta success=false, message indica error de duplicidad.

## 4. Validación de Año y Trimestre
- **Entrada:** año=1990, trimestre=5
- **Acción:** POST /api/execute { action: 'generarAdeudos', params: { ano: 1990, trimestre: 5 } }
- **Esperado:** Respuesta success=false, message indica error de validación.

## 5. Error de Base de Datos
- **Simulación:** Desconectar base de datos
- **Acción:** POST /api/execute { action: 'insertarAdeudos', params: { ... } }
- **Esperado:** Respuesta success=false, message indica error de conexión.
