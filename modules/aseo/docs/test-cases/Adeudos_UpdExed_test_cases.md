## Casos de Prueba: Adeudos_UpdExed

### 1. Búsqueda exitosa de excedencia
- **Entrada:** contrato=12345, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7
- **Acción:** Buscar
- **Esperado:** Se muestra la cantidad actual de excedencias y formulario de actualización.

### 2. Actualización exitosa de excedencia
- **Entrada:** contrato=12345, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7, cantidad=20, oficio="OF-2024-002", usuario=1
- **Acción:** Actualizar
- **Esperado:** Mensaje de éxito y la cantidad se actualiza en la base de datos.

### 3. Búsqueda de excedencia inexistente
- **Entrada:** contrato=99999, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7
- **Acción:** Buscar
- **Esperado:** Mensaje de error "No existe excedencia vigente".

### 4. Validación de campos obligatorios
- **Entrada:** contrato vacío, ctrol_aseo=9, ejercicio=2024, mes=6, ctrol_operacion=7
- **Acción:** Buscar
- **Esperado:** Mensaje de error "Datos incompletos".

### 5. Error de base de datos
- **Simulación:** Desconectar base de datos y realizar búsqueda
- **Esperado:** Mensaje de error técnico.

### 6. Catálogos
- **Acción:** Cargar página
- **Esperado:** Se cargan correctamente los catálogos de tipos de aseo, tipos de operación y meses.
