# Casos de Prueba PasoMdos

## 1. Migración exitosa de nuevos registros
- **Preparación:**
  - Insertar en cobrotrimestral: Folio=3001, Nombre='MARIA LOPEZ', Domicilio='CALLE 1', Superficie=12, Giro='ROPA', Descuento=0, MotivoDescuento=''
  - Asegurarse que Folio=3001 no existe en ta_11_locales
- **Ejecución:**
  - Ejecutar acción 'migrar_tianguis_a_padron'
- **Verificación:**
  - El registro aparece en ta_11_locales
  - El resultado muestra errores=0, existentes=0

## 2. Migración con registros existentes
- **Preparación:**
  - Insertar en cobrotrimestral: Folio=4001, ...
  - Insertar en ta_11_locales un registro con local=4001, oficina=1, num_mercado=214, categoria=1, seccion='SS'
- **Ejecución:**
  - Ejecutar acción 'migrar_tianguis_a_padron'
- **Verificación:**
  - El resultado muestra errores=0, existentes=1

## 3. Migración con error de datos
- **Preparación:**
  - Insertar en cobrotrimestral: Folio=5001, Nombre='INVALIDO', Superficie=-10
- **Ejecución:**
  - Ejecutar acción 'migrar_tianguis_a_padron'
- **Verificación:**
  - El resultado muestra errores=1, existentes=0
  - El error indica el folio y el mensaje de error de la base de datos
