<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue';

$content = file_get_contents($file);

// 1. Cambiar parámetros de inglés a español en reload()
$oldReload = "async function reload() {
  const params = [
    { name: 'clave_cuenta', type: 'C', value: String(filters.value.cuenta || '') },
    { name: 'ejercicio', type: 'I', value: Number(filters.value.ejercicio || 0) }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    rows.value = Array.isArray(data) ? data : []
  } catch (e) { rows.value = [] }
}";

$newReload = "async function reload() {
  searchPerformed.value = true
  resetPagination()

  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'integer', valor: Number(filters.value.ejercicio || 0) }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    processResults(data)
  } catch (e) {
    rows.value = []
    cols.value = []
  }
}";

$content = str_replace($oldReload, $newReload, $content);

// 2. Cambiar parámetros en save()
$content = str_replace(
    "{ name: 'registro', type: 'C', value: JSON.stringify(form.value) }",
    "{ nombre: 'registro', tipo: 'string', valor: JSON.stringify(form.value) }",
    $content
);

// 3. Agregar imports de computed
$content = str_replace(
    "import { ref } from 'vue'",
    "import { ref, computed } from 'vue'",
    $content
);

// 4. Agregar variables para paginación y búsqueda después de rows
$oldRowsDef = "const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])";

$newRowsDef = "const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])
const cols = ref([])
const searchPerformed = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage)
})

const startIndex = computed(() => {
  return (currentPage.value - 1) * itemsPerPage
})

const endIndex = computed(() => {
  return Math.min(startIndex.value + itemsPerPage, rows.value.length)
})

const paginatedRows = computed(() => {
  return rows.value.slice(startIndex.value, endIndex.value)
})

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function previousPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function resetPagination() {
  currentPage.value = 1
}

function processResults(data) {
  let arr = []

  if (data?.result && Array.isArray(data.result)) {
    arr = data.result
  } else if (data?.rows && Array.isArray(data.rows)) {
    arr = data.rows
  } else if (Array.isArray(data)) {
    arr = data
  }

  rows.value = arr
  cols.value = arr.length ? Object.keys(arr[0]) : []
}";

$content = str_replace($oldRowsDef, $newRowsDef, $content);

// 5. Cambiar el tbody para usar paginatedRows
$content = str_replace(
    '<tr v-for="(r, idx) in rows" :key="idx" class="row-hover">',
    '<tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">',
    $content
);

// 6. Agregar header de resultados antes de la tabla
$oldTableStart = '        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">';

$newTableStart = '        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="results-header" v-if="rows.length > 0">
            <h3>Resultados: {{ rows.length }} registros encontrados</h3>
          </div>
          <div class="table-responsive">';

$content = str_replace($oldTableStart, $newTableStart, $content);

// 7. Agregar paginación después de la tabla
$oldTableEnd = '              </tbody>
            </table>
          </div>
        </div>
      </div>';

$newTableEnd = '              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="rows.length > 0">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="previousPage"
              >
                ‹ Anterior
              </button>
              <span class="page-info">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="nextPage"
              >
                Siguiente ›
              </button>
            </div>
          </div>
        </div>
      </div>';

$content = str_replace($oldTableEnd, $newTableEnd, $content);

// 8. Agregar CSS para paginación al final del <style> existente (antes del </style>)
$paginationCSS = "
.results-header {
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #007bff;
}

.results-header h3 {
  font-size: 1.1rem;
  color: #333;
  margin: 0;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 4px;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 1rem;
}

.pagination-info {
  font-size: 0.9rem;
  color: #666;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.btn-pagination {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #0056b3;
}

.btn-pagination:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.page-info {
  font-size: 0.9rem;
  color: #333;
  font-weight: 500;
}
";

// Si hay un tag </style>, agregar antes de él
if (strpos($content, '</style>') !== false) {
    $content = str_replace('</style>', $paginationCSS . '</style>', $content);
} else {
    // Si no hay styles, agregar al final
    $content .= "\n<style scoped>" . $paginationCSS . "</style>\n";
}

file_put_contents($file, $content);

echo "✅ Archivo ReqTrans.vue actualizado exitosamente\n";
echo "   - Parámetros cambiados a español (nombre, tipo, valor)\n";
echo "   - Paginación agregada (10 registros por página)\n";
echo "   - Procesamiento de data.result implementado\n";
echo "   - Header de resultados agregado\n";
echo "   - Controles de paginación agregados\n";
