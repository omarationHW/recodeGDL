<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Registro, Secretaría y Más</h1>
        <p>Búsqueda de ejecutores administrativos</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>🔍 Búsqueda de Ejecutores</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">Buscar por nombre, RFC, o clave</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtro"
                @keyup.enter="buscar"
                placeholder="Ej: JAVIER, CEGJ, 154..."
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="buscar"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Buscando...</span>
              <span v-else>Buscar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="todosResultados.length > 0">
        <div class="municipal-card-header">
          <h5>✅ Resultados ({{ todosResultados.length }} ejecutores encontrados)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Clave</th>
                  <th>Nombre</th>
                  <th>RFC Inicial</th>
                  <th>Homoclave</th>
                  <th>Recaudación</th>
                  <th>Categoría</th>
                  <th>Vigencia</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultadosPaginados" :key="idx" class="row-hover">
                  <td style="font-weight: 600;">{{ row.id_ejecutor }}</td>
                  <td>{{ row.cve_eje }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.ini_rfc || '-' }}</td>
                  <td>{{ row.hom_rfc || '-' }}</td>
                  <td>{{ row.id_rec }}</td>
                  <td>{{ row.categoria || '-' }}</td>
                  <td>{{ row.vigencia || '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ rangoInicio }}-{{ rangoFin }} de {{ todosResultados.length }} registros
            </div>

            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="paginaActual === 1"
                @click="cambiarPagina(1)"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-pagination"
                :disabled="paginaActual === 1"
                @click="cambiarPagina(paginaActual - 1)"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <span class="pagination-text">
                Página {{ paginaActual }} de {{ totalPaginas }}
              </span>

              <button
                class="btn-pagination"
                :disabled="paginaActual === totalPaginas"
                @click="cambiarPagina(paginaActual + 1)"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-pagination"
                :disabled="paginaActual === totalPaginas"
                @click="cambiarPagina(totalPaginas)"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div class="municipal-card" v-if="!loading && todosResultados.length === 0 && buscado">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <strong>Sin resultados:</strong> No se encontraron ejecutores con el criterio de búsqueda.
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REGSECYMAS'
const { loading, execute } = useApi()

const filtro = ref('')
const todosResultados = ref([])
const paginaActual = ref(1)
const registrosPorPagina = 10
const error = ref(null)
const buscado = ref(false)

// Computed para paginación
const totalPaginas = computed(() => {
  return Math.ceil(todosResultados.value.length / registrosPorPagina)
})

const resultadosPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * registrosPorPagina
  const fin = inicio + registrosPorPagina
  return todosResultados.value.slice(inicio, fin)
})

const rangoInicio = computed(() => {
  if (todosResultados.value.length === 0) return 0
  return (paginaActual.value - 1) * registrosPorPagina + 1
})

const rangoFin = computed(() => {
  const fin = paginaActual.value * registrosPorPagina
  return fin > todosResultados.value.length ? todosResultados.value.length : fin
})

async function buscar() {
  error.value = null
  buscado.value = true
  paginaActual.value = 1

  try {
    console.log('🔍 Ejecutando búsqueda:', OP)
    console.log('🔍 Filtro:', filtro.value)

    // Enviar parámetros en el formato correcto
    const params = [
      {
        nombre: 'p_busqueda',
        valor: filtro.value || '',
        tipo: 'string'
      }
    ]

    const data = await execute(OP, BASE_DB, params)

    console.log('✅ Resultado:', data)

    // Procesar respuesta
    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    todosResultados.value = arr

  } catch (e) {
    error.value = e.message || 'Error al buscar ejecutores'
    console.error('❌ Error:', e)
    todosResultados.value = []
  }
}

function limpiar() {
  filtro.value = ''
  todosResultados.value = []
  paginaActual.value = 1
  error.value = null
  buscado.value = false
}

function cambiarPagina(nuevaPagina) {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
  }
}

// Cargar todos los ejecutores al montar
onMounted(() => {
  buscar()
})
</script>

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
  border-radius: 8px 8px 0 0;
}

.municipal-card-header h5 {
  margin: 0;
  color: white;
}

.municipal-card-body {
  padding: 20px;
}

.form-row {
  display: flex;
  gap: 15px;
  margin-bottom: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.municipal-form-label {
  font-weight: 600;
  margin-bottom: 5px;
  color: #333;
}

.municipal-form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.municipal-table-header {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
}

.municipal-table th {
  font-weight: bold;
  color: white;
  font-size: 0.9rem;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.table-responsive {
  overflow-x: auto;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 2px solid #ea8215;
}

.pagination-info {
  color: #666;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  gap: 8px;
  align-items: center;
}

.btn-pagination {
  background: white;
  border: 1px solid #ddd;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #ea8215;
}

.btn-pagination:hover:not(:disabled) {
  background: #ea8215;
  color: white;
  border-color: #ea8215;
}

.btn-pagination:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.pagination-text {
  color: #333;
  font-weight: 600;
  padding: 0 10px;
}

.alert {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c2c7;
  color: #842029;
}

.alert-info {
  background-color: #cfe2ff;
  border: 1px solid #b6d4fe;
  color: #084298;
}
</style>
