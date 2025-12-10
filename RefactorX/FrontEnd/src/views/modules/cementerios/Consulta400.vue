<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search-plus" />
      </div>
      <div class="module-view-info">
        <h1>Consulta por R.C.M en 400</h1>
        <p>Cementerios - Consulta avanzada JOIN Fosas + Pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Sección de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda por Ubicación Completa
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Cementerio -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Cementerio</label>
              <select
                class="municipal-form-control"
                v-model="busqueda.cementerio"
              >
                <option value="">Seleccione...</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.cementerio }} - {{ cem.nombre }}
                </option>
              </select>
            </div>
          </div>

          <!-- Ubicación: Clase y Sección -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Clase</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.clase"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Clase Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.clase_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Sección</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.seccion"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.seccion_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
          </div>

          <!-- Ubicación: Línea y Fosa -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Línea</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.linea"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Línea Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.linea_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Fosa</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.fosa"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fosa Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.fosa_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
          </div>

          <!-- Botones -->
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="verificarBusqueda"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Verificar
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

      <!-- Resultados -->
      <div class="municipal-card" v-if="resultados.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados Encontrados
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ formatNumber(totalRecords) }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Cementerio</th>
                  <th>Titular</th>
                  <th>Ubicación</th>
                  <th>Año Pagado</th>
                  <th>Fecha Pago</th>
                  <th>Recibo</th>
                  <th>Años (Desde-Hasta)</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(resultado, index) in paginatedResultados" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ resultado.control_rcm }}</strong></td>
                  <td>{{ resultado.cement }}</td>
                  <td>{{ resultado.nomb }}</td>
                  <td><small>{{ formatearUbicacion(resultado) }}</small></td>
                  <td>{{ resultado.ppag }}</td>
                  <td><small>{{ formatearFecha(resultado.fecing) }}</small></td>
                  <td>{{ resultado.recing }}</td>
                  <td><small>{{ resultado.ppagd }} - {{ resultado.ppagh }}</small></td>
                  <td><strong>${{ formatearMoneda(resultado.imppag) }}</strong></td>
                  <td><strong>${{ formatearMoneda(resultado.imprec) }}</strong></td>
                  <td>
                    <span class="badge badge-success" v-if="resultado.vigencia === 'A'">
                      <font-awesome-icon icon="check-circle" />
                      Activo
                    </span>
                    <span class="badge badge-danger" v-else>
                      <font-awesome-icon icon="times-circle" />
                      Baja
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="resultados.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-else-if="busquedaRealizada" class="municipal-card">
        <div class="municipal-card-body text-center">
          <font-awesome-icon icon="info-circle" class="text-info" size="2x" />
          <p class="mt-2">No se encontraron registros con la ubicación especificada</p>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Consulta400'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const loading = ref(false)
const showDocumentation = ref(false)
const busquedaRealizada = ref(false)
const cementerios = ref([])
const resultados = ref([])

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => resultados.value.length)

const busqueda = reactive({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: ''
})

// Métodos
onMounted(async () => {
  await cargarCementerios()
})

const cargarCementerios = async () => {
  try {
    /* TODO FUTURO: Query SQL original (consulta400.dfm líneas 1442-1443):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select * from tc_13_cementerios'
    */
//    para mejorar el performance se manda a llamar sp_get_cementerios_list
    const response = await execute(
      //'sp_consulta400_listar_cementerios',
      'sp_get_cementerios_list',
      'cementerio',
      [],
      'function',
      null,
      'public'
    )

    if(response?.result?.length > 0) {
      cementerios.value = response.result
    }

  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showToast('error', 'Error al cargar cementerios: ' + error.message)
  }
}

const verificarBusqueda = async () => {
  // Validaciones
  if (!busqueda.cementerio) {
    showToast('warning', 'Seleccione un cementerio')
    return
  }
  if (!busqueda.clase || !busqueda.seccion || !busqueda.linea || !busqueda.fosa) {
    showToast('warning', 'Complete la ubicación completa (clase, sección, línea, fosa)')
    return
  }

  loading.value = true
  showLoading('Buscando...', 'Consultando base de datos')
  currentPage.value = 1

  try {
    /* TODO FUTURO: Query SQL original (consulta400.pas líneas 231-256, .dfm líneas 1490-1497):
    -- DatabaseName: cementerio (400, 401, 402, 403)
    -- SQL: 'select a.*,b.* from cmf01dcem a, cmf01pcem b
    --       where a.cement=:vcem and a.clase=:vclase and a.clasal=:vclasealfa
    --       and a.SECC=:vsecc and a.SECCAL=:vseccalfa
    --       and a.LINEA=:vlinea and a.LINEAL=:vlinealfa
    --       and a.FOSA=:vfosa and a.FOSAAL=:vfosalafa
    --       and a.cement=b.cementp and a.clase=b.clasep and a.clasal=b.clasalp
    --       and a.SECC=b.seccp and a.SECCAL=b.SECCALp
    --       and a.LINEA=b.lineap and a.LINEAL=b.linealp
    --       and a.FOSA=b.fosap and a.FOSAAL=b.fosaalp'
    -- Nota: JOIN entre fosas (cmf01dcem = ta_13_datosrcm) y pagos (cmf01pcem = ta_13_pagosrcm)
    */

    const response = await execute(
      'sp_consulta400_buscar_por_ubicacion',
      'cementerio',
      [
        { nombre: 'p_cementerio', valor: busqueda.cementerio, tipo: 'varchar' },
        { nombre: 'p_clase', valor: busqueda.clase, tipo: 'smallint' },
        { nombre: 'p_clase_alfa', valor: busqueda.clase_alfa || '', tipo: 'varchar' },
        { nombre: 'p_seccion', valor: busqueda.seccion, tipo: 'smallint' },
        { nombre: 'p_seccion_alfa', valor: busqueda.seccion_alfa || '', tipo: 'varchar' },
        { nombre: 'p_linea', valor: busqueda.linea, tipo: 'smallint' },
        { nombre: 'p_linea_alfa', valor: busqueda.linea_alfa || '', tipo: 'varchar' },
        { nombre: 'p_fosa', valor: busqueda.fosa, tipo: 'smallint' },
        { nombre: 'p_fosa_alfa', valor: busqueda.fosa_alfa || '', tipo: 'varchar' }
      ],
      'function',
      null,
      'public'
    )

    if(response?.result?.length > 0) {
      resultados.value = response.result
    } else {
      resultados.value = []
    }
    busquedaRealizada.value = true

    if (resultados.value.length > 0) {
      showToast('success', `Se encontraron ${resultados.value.length} registro(s)`)
    } else {
      showToast('info', 'No se encontraron registros con la ubicación especificada')
    }
  } catch (error) {
    console.error('Error al buscar:', error)
    showToast('error', 'Error al realizar la búsqueda: ' + error.message)
    resultados.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiar = () => {
  busqueda.cementerio = ''
  busqueda.clase = null
  busqueda.clase_alfa = ''
  busqueda.seccion = null
  busqueda.seccion_alfa = ''
  busqueda.linea = null
  busqueda.linea_alfa = ''
  busqueda.fosa = null
  busqueda.fosa_alfa = ''
  resultados.value = []
  busquedaRealizada.value = false
}

const mostrarAyuda = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const formatearUbicacion = (resultado) => {
  const partes = []
  partes.push(`Cl:${resultado.clase}${resultado.clasal || ''}`)
  partes.push(`Sec:${resultado.secc}${resultado.seccal || ''}`)
  partes.push(`Lin:${resultado.linea}${resultado.lineal || ''}`)
  partes.push(`Fosa:${resultado.fosa}${resultado.fosaal || ''}`)
  return partes.join(' ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return resultados.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}
</script>
