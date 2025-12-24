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
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'RegSecyMas'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Registro, Secretaría y Más'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'RegSecyMas'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Registro, Secretaría y Más'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REGSECYMAS'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

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
    showLoading('Consultando...', 'Por favor espere')
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
  } finally {
    hideLoading()
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

