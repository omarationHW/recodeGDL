# 3 EJEMPLOS PARA PROBAR EL FORMULARIO reimpfrm.vue

## ✅ Stored Procedure Creado
- **Nombre:** `public.recaudadora_reimpfrm`
- **Módulo:** multas_reglamentos
- **Funcionalidad:** Búsqueda de documentos para reimpresión con paginación de 10 en 10

---

## 📋 EJEMPLO 1: Buscar Multa Específica de Reglamentos

### Campos del formulario:
```
Tipo de Documento:  multa
Folio / ID:         170736
Dependencia:        7 - Reglamentos
Formato:            original
```

### Resultado esperado:
```
✅ 1 documento encontrado

Tabla mostrará:
- Folio: 170736
- Tipo: multa
- Contribuyente: JOSEFINA RUVALCABA PEREZ
- Dependencia: 7
- Año Acta: 2004
- Num Acta: 26260
- Importe: $400.00
- Estatus: PAGADO
```

---

## 📋 EJEMPLO 2: Buscar Multa Específica de Tránsito

### Campos del formulario:
```
Tipo de Documento:  multa
Folio / ID:         170780
Dependencia:        3 - Tránsito
Formato:            copia
```

### Resultado esperado:
```
✅ 1 documento encontrado

Tabla mostrará:
- Folio: 170780
- Tipo: multa
- Contribuyente: DAMIAN ASCENCIO IGNACIO MARTIN
- Dependencia: 3
- Año Acta: 2004
- Num Acta: 954
- Importe: $50.00
- Estatus: PAGADO
```

---

## 📋 EJEMPLO 3: Buscar Todas las Multas (Sin Folio)

### Campos del formulario:
```
Tipo de Documento:  multa
Folio / ID:         (dejar vacío)
Dependencia:        Todas
Formato:            duplicado
```

### Resultado esperado:
```
✅ 100 documentos encontrados (límite del SP)

Tabla mostrará hasta 100 multas más recientes con paginación de 10 en 10:
- Página 1: Registros 1-10
- Página 2: Registros 11-20
- ... (hasta 10 páginas)

Controles de paginación:
- Primera página (<<)
- Anterior (<)
- Página actual / Total
- Siguiente (>)
- Última página (>>)
```

---

## 🔍 CARACTERÍSTICAS IMPLEMENTADAS

### Funcionalidad de Búsqueda:
- ✅ Buscar por folio específico
- ✅ Buscar sin folio (todos los documentos)
- ✅ Filtrar por dependencia (opcional)
- ✅ Filtrar por tipo de documento
- ✅ Seleccionar formato de impresión

### Tabla de Resultados:
- ✅ Muestra 10 registros por página
- ✅ Información completa de cada documento
- ✅ Estatus con colores (PAGADO=verde, PENDIENTE=amarillo, CANCELADO=rojo)
- ✅ Botones de acción por documento (Vista Previa, Descargar PDF)

### Paginación:
- ✅ Navegación completa (Primera, Anterior, Siguiente, Última)
- ✅ Indicador de página actual y total
- ✅ Contador de registros (Mostrando X-Y de Z)
- ✅ Botones deshabilitados cuando no aplican

---

## 📊 DATOS REALES UTILIZADOS

### Tabla: `comun.multas`
- **Total registros:** 415,017 multas
- **Registros con contribuyente:** Filtrados automáticamente
- **Dependencias disponibles:**
  - Dep. 7: 203,673 multas (Reglamentos)
  - Dep. 5: 82,141 multas
  - Dep. 35: 49,965 multas
  - Dep. 3: 35,264 multas (Tránsito)
  - Dep. 4: 16,914 multas

### Campos mostrados:
- Folio (id_multa)
- Tipo de documento
- Fecha (fecha_acta)
- Contribuyente
- Dependencia (id_dependencia)
- Año Acta (axo_acta)
- Num Acta (num_acta)
- Importe (total)
- Estatus (calculado: PAGADO/PENDIENTE/CANCELADO)

---

## 🎯 CÓMO PROBAR

1. **Buscar documento específico:**
   - Usa el Ejemplo 1 o 2
   - Ingresa el folio exacto
   - Verás 1 resultado

2. **Buscar múltiples documentos:**
   - Usa el Ejemplo 3
   - Deja el folio vacío
   - Verás hasta 100 resultados con paginación

3. **Navegar entre páginas:**
   - Usa los botones << < > >>
   - Observa el contador de registros
   - Cada página muestra 10 documentos

4. **Acciones por documento:**
   - Botón 👁️ Vista Previa: Muestra alert con info
   - Botón ⬇️ Descargar PDF: Muestra alert (por implementar)

---

## 🚀 ESTADO ACTUAL

✅ **COMPLETADO:**
- Stored Procedure creado y desplegado
- Componente Vue actualizado con tabla y paginación
- 3 ejemplos con datos reales documentados
- Búsqueda flexible (con o sin folio)
- Paginación de 10 en 10 implementada
- Estilos y diseño completos

🔄 **POR IMPLEMENTAR (futuro):**
- Generación real de PDFs
- Vista previa de documentos
- Búsqueda de recibos, requerimientos y actas
- Impresión directa desde el navegador
