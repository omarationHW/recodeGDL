<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percentage" />
      </div>
      <div class="module-view-info">
        <h1>Descuentos</h1>
        <p>Cementerios - Aplicación de descuentos a folios</p>
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

    <!-- Paso 1: Búsqueda de Folio -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Paso 1: Búsqueda de Folio
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Folio</label>
            <input
              type="number"
              v-model.number="folioSearch"
              class="municipal-form-control"
              placeholder="Ingrese número de folio"
              @keyup.enter="buscarFolio"
            />
          </div>
          <div class="form-group align-end">
            <button
              class="btn-municipal-primary"
              @click="buscarFolio"
              :disabled="!folioSearch || folioSearch <= 0"
            >
              <font-awesome-icon icon="search" />
              Buscar Folio
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 2: Información del Folio -->
    <div v-if="folioData" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="info-circle" />
        Paso 2: Información del Folio
      </div>
      <div class="municipal-card-body">
        <div class="info-section">
          <h3 class="info-title">Datos del Folio</h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Folio:</span>
              <span class="info-value">{{ folioData.control_rcm }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Cementerio:</span>
              <span class="info-value">{{ folioData.cementerio }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Clase:</span>
              <span class="info-value">{{ folioData.clase_alfa }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Sección:</span>
              <span class="info-value">{{ folioData.seccion_alfa }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Línea:</span>
              <span class="info-value">{{ folioData.linea_alfa }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Fosa:</span>
              <span class="info-value">{{ folioData.fosa_alfa }}</span>
            </div>
            <div class="info-item full-width">
              <span class="info-label">Nombre:</span>
              <span class="info-value">{{ folioData.nombre }}</span>
            </div>
            <div class="info-item full-width">
              <span class="info-label">Domicilio:</span>
              <span class="info-value">
                {{ folioData.domicilio }}
                {{ folioData.exterior ? 'Ext. ' + folioData.exterior : '' }}
                {{ folioData.interior ? 'Int. ' + folioData.interior : '' }}
              </span>
            </div>
            <div class="info-item full-width">
              <span class="info-label">Colonia:</span>
              <span class="info-value">{{ folioData.colonia }}</span>
            </div>
          </div>
        </div>

        <!-- Adeudos -->
        <div v-if="adeudos.length > 0" class="mt-3">
          <h3 class="info-title">Adeudos Vigentes</h3>
          <div class="table-container">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                  <th>Desc. Importe</th>
                  <th>Desc. Recargos</th>
                  <th>Total</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in paginatedAdeudos" :key="adeudo.id_adeudo">
                  <td>{{ adeudo.axo_adeudo }}</td>
                  <td>{{ formatCurrency(adeudo.importe) }}</td>
                  <td>{{ formatCurrency(adeudo.importe_recargos) }}</td>
                  <td>{{ formatCurrency(adeudo.descto_impote) }}</td>
                  <td>{{ formatCurrency(adeudo.descto_recargos) }}</td>
                  <td class="text-bold">
                    {{ formatCurrency(calcularTotalAdeudo(adeudo)) }}
                  </td>
                  <td>
                    <button
                      v-if="!tieneDescuento(adeudo.axo_adeudo)"
                      class="btn-action-primary"
                      @click="seleccionarAdeudo(adeudo)"
                      title="Aplicar descuento"
                    >
                      <font-awesome-icon icon="plus" />
                    </button>
                    <span v-else class="badge-success">Con descuento</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="adeudos.length > 0" class="pagination-controls mt-3">
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

        <!-- Sin adeudos - Opción de reactivar -->
        <div v-if="adeudos.length === 0" class="alert-info mt-3">
          <font-awesome-icon icon="info-circle" />
          <div>
            <strong>Sin adeudos vigentes</strong>
            <p>Este folio no tiene adeudos vigentes. Puede reactivarlo si es necesario.</p>
            <div class="form-group mt-2">
              <label class="checkbox-label">
                <input type="checkbox" v-model="modoReactivar" />
                Reactivar folio
              </label>
            </div>
            <button
              v-if="modoReactivar"
              class="btn-municipal-primary mt-2"
              @click="reactivarFolio"
            >
              <font-awesome-icon icon="redo" />
              Reactivar Folio
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 3: Aplicar Descuento -->
    <div v-if="adeudoSeleccionado" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="tag" />
        Paso 3: Aplicar Descuento al Año {{ adeudoSeleccionado.axo_adeudo }}
      </div>
      <div class="municipal-card-body">
        <div class="alert-info mb-3">
          <font-awesome-icon icon="info-circle" />
          <span>Seleccione el tipo de descuento a aplicar</span>
        </div>

        <div v-if="tiposDescuento.length > 0" class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Tipo de Descuento</label>
            <select v-model="descuentoSeleccionado" class="municipal-form-control">
              <option :value="null">-- Seleccione --</option>
              <option
                v-for="tipo in tiposDescuento"
                :key="tipo.tipo_descto"
                :value="tipo"
              >
                {{ tipo.tipo_descto }} - {{ tipo.descrip_descto }} ({{ tipo.porcentaje }}%)
              </option>
            </select>
          </div>
        </div>

        <div v-if="descuentoSeleccionado" class="summary-box mt-3">
          <div class="summary-item">
            <span class="summary-label">Importe Base:</span>
            <span class="summary-value">{{ formatCurrency(adeudoSeleccionado.importe) }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Recargos:</span>
            <span class="summary-value">{{ formatCurrency(adeudoSeleccionado.importe_recargos) }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Porcentaje Descuento:</span>
            <span class="summary-value primary">{{ descuentoSeleccionado.porcentaje }}%</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Descuento Importe:</span>
            <span class="summary-value success">
              {{ formatCurrency(calcularDescuento(adeudoSeleccionado.importe)) }}
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Descuento Recargos:</span>
            <span class="summary-value success">
              {{ formatCurrency(calcularDescuento(adeudoSeleccionado.importe_recargos)) }}
            </span>
          </div>
          <div class="summary-item total">
            <span class="summary-label">Total con Descuento:</span>
            <span class="summary-value">
              {{ formatCurrency(calcularTotalConDescuento()) }}
            </span>
          </div>
        </div>

        <div class="form-actions">
          <button
            class="btn-municipal-secondary"
            @click="cancelarDescuento"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button
            class="btn-municipal-primary"
            @click="aplicarDescuento"
            :disabled="!descuentoSeleccionado"
          >
            <font-awesome-icon icon="save" />
            Aplicar Descuento
          </button>
        </div>
      </div>
    </div>

    <!-- Paso 4: Descuentos Aplicados -->
    <div v-if="descuentosAplicados.length > 0" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Descuentos Aplicados
      </div>
      <div class="municipal-card-body">
        <div class="table-container">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Año</th>
                <th>Tipo</th>
                <th>Descripción</th>
                <th>Descuento %</th>
                <th>Usuario</th>
                <th>Fecha</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="desc in descuentosAplicados" :key="desc.control_des">
                <td>{{ desc.axo_descto }}</td>
                <td>{{ desc.tipo_descto }}</td>
                <td>{{ desc.descrip_descto }}</td>
                <td>{{ desc.descuento }}%</td>
                <td>{{ desc.nombre }}</td>
                <td>{{ formatDate(desc.fecha_alta) }}</td>
                <td>
                  <span :class="desc.vigencia === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ desc.vigencia === 'V' ? 'Vigente' : 'Cancelado' }}
                  </span>
                </td>
                <td>
                  <button
                    v-if="desc.vigencia === 'V'"
                    class="btn-action-danger"
                    @click="eliminarDescuento(desc)"
                    title="Cancelar descuento"
                  >
                    <font-awesome-icon icon="trash" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
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
      :componentName="'Descuentos'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

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

// Estado
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const folioSearch = ref(null)
const folioData = ref(null)
const adeudos = ref([])
const adeudoSeleccionado = ref(null)
const tiposDescuento = ref([])
const descuentoSeleccionado = ref(null)
const descuentosAplicados = ref([])
const modoReactivar = ref(false)

// Paginación para tabla de adeudos
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed - Paginación
const totalRecords = computed(() => adeudos.value.length)

const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedAdeudos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return adeudos.value.slice(start, end)
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

// Buscar folio
const buscarFolio = async () => {
  if (!folioSearch.value || folioSearch.value <= 0) {
    showToast('warning', 'Por favor ingrese un número de folio válido')
    return
  }

  showLoading('Buscando folio...', 'Consultando base de datos')

  try {
    // Buscar folio - sp_descuentos_buscar_folio
    const response = await execute(
      'sp_descuentos_buscar_folio',
      'padron_licencias',
      [
        { nombre: 'p_control_rcm', valor: folioSearch.value, tipo: 'integer' }
      ],
      '',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      folioData.value = response.result[0]
      await cargarAdeudos()
      await cargarDescuentos()
      await cargarTiposDescuento()
      showToast('success', 'Folio encontrado')
    } else {
      showToast('error', 'Folio no encontrado')
      limpiarDatos()
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar el folio')
    limpiarDatos()
  } finally {
    hideLoading()
  }
}

// Cargar adeudos del folio
const cargarAdeudos = async () => {
  try {
    const response = await execute(
      'sp_descuentos_listar_adeudos',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioSearch.value, tipo: 'integer' }
      ],
      'cementerio',
      null,
      'public'
    )

    adeudos.value = response?.result || []
    currentPage.value = 1 // Reset paginación al cargar nuevos datos
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    adeudos.value = []
  }
}

// Cargar descuentos aplicados
const cargarDescuentos = async () => {
  try {
    const response = await execute(
      'sp_descuentos_listar_descuentos_aplicados',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioSearch.value, tipo: 'integer' }
      ],
      'cementerio',
      null,
      'public'
    )

    descuentosAplicados.value = response?.result || []
  } catch (error) {
    console.error('Error al cargar descuentos:', error)
    descuentosAplicados.value = []
  }
}

// Cargar tipos de descuento
const cargarTiposDescuento = async () => {
  try {
    const currentYear = new Date().getFullYear()
    const response = await execute(
      'sp_descuentos_listar_tipos_descuento',
      'cementerio',
      [
        { nombre: 'p_axo', valor: currentYear, tipo: 'integer' }
      ],
      'cementerio',
      null,
      'public'
    )

    tiposDescuento.value = response?.result || []
  } catch (error) {
    console.error('Error al cargar tipos de descuento:', error)
    tiposDescuento.value = []
  }
}

// Verificar si un año ya tiene descuento
const tieneDescuento = (axo) => {
  return descuentosAplicados.value.some(
    d => d.axo_descto === axo && d.vigencia === 'V'
  )
}

// Seleccionar adeudo para aplicar descuento
const seleccionarAdeudo = (adeudo) => {
  adeudoSeleccionado.value = adeudo
  descuentoSeleccionado.value = null
}

// Calcular descuento
const calcularDescuento = (monto) => {
  if (!descuentoSeleccionado.value) return 0
  return (monto * descuentoSeleccionado.value.porcentaje) / 100
}

// Calcular total con descuento
const calcularTotalConDescuento = () => {
  if (!adeudoSeleccionado.value || !descuentoSeleccionado.value) return 0

  const importe = parseFloat(adeudoSeleccionado.value.importe || 0)
  const recargos = parseFloat(adeudoSeleccionado.value.importe_recargos || 0)
  const total = importe + recargos
  const descuento = calcularDescuento(importe) + calcularDescuento(recargos)

  return total - descuento
}

// Aplicar descuento
const aplicarDescuento = async () => {
  if (!descuentoSeleccionado.value) {
    showToast('warning', 'Seleccione un tipo de descuento')
    return
  }

  showLoading('Aplicando descuento...', 'Guardando en base de datos')

  try {
    // spd_13_abcdesctos - Operación 1 = Alta
    const response = await execute(
      'spd_13_abcdesctos',
      'cementerio',
      [
        { nombre: 'v_control', valor: folioSearch.value, tipo: 'integer' },
        { nombre: 'v_axo', valor: adeudoSeleccionado.value.axo_adeudo, tipo: 'integer' },
        { nombre: 'v_porc', valor: descuentoSeleccionado.value.porcentaje, tipo: 'integer' },
        { nombre: 'v_usu', valor: 1, tipo: 'integer' }, // TODO: Obtener de sesión
        { nombre: 'v_reac', valor: 'N', tipo: 'string' },
        { nombre: 'v_tipo_descto', valor: descuentoSeleccionado.value.tipo_descto, tipo: 'string' },
        { nombre: 'v_opc', valor: 1, tipo: 'integer' } // 1 = Alta
      ],
      'cementerio',
      null,
      'public'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]
      if (resultado.par_ok === 0) {
        showToast('success', resultado.par_observ || 'Descuento aplicado correctamente')
        await cargarAdeudos()
        await cargarDescuentos()
        cancelarDescuento()
      } else {
        showToast('error', resultado.par_observ || 'Error al aplicar descuento')
      }
    } else {
      showToast('error', 'Error al aplicar descuento')
    }
  } catch (error) {
    console.error('Error al aplicar descuento:', error)
    showToast('error', 'Error al aplicar el descuento')
  } finally {
    hideLoading()
  }
}

// Cancelar selección de descuento
const cancelarDescuento = () => {
  adeudoSeleccionado.value = null
  descuentoSeleccionado.value = null
}

// Eliminar descuento
const eliminarDescuento = async (descuento) => {
  const result = await Swal.fire({
    title: '¿Cancelar descuento?',
    text: `Se cancelará el descuento del ${descuento.descuento}% para el año ${descuento.axo_descto}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  showLoading('Cancelando descuento...', 'Actualizando base de datos')

  try {
    // spd_13_abcdesctos - Operación 2 = Baja
    const response = await execute(
      'spd_13_abcdesctos',
      'cementerio',
      [
        { nombre: 'v_control', valor: folioSearch.value, tipo: 'integer' },
        { nombre: 'v_axo', valor: descuento.axo_descto, tipo: 'integer' },
        { nombre: 'v_porc', valor: descuento.descuento, tipo: 'integer' },
        { nombre: 'v_usu', valor: 1, tipo: 'integer' }, // TODO: Obtener de sesión
        { nombre: 'v_reac', valor: 'N', tipo: 'string' },
        { nombre: 'v_tipo_descto', valor: descuento.tipo_descto, tipo: 'string' },
        { nombre: 'v_opc', valor: 2, tipo: 'integer' } // 2 = Baja
      ],
      'cementerio',
      null,
      'public'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]
      if (resultado.par_ok === 0) {
        showToast('success', resultado.par_observ || 'Descuento cancelado correctamente')
        await cargarAdeudos()
        await cargarDescuentos()
      } else {
        showToast('error', resultado.par_observ || 'Error al cancelar descuento')
      }
    } else {
      showToast('error', 'Error al cancelar descuento')
    }
  } catch (error) {
    console.error('Error al cancelar descuento:', error)
    showToast('error', 'Error al cancelar el descuento')
  } finally {
    hideLoading()
  }
}

// Reactivar folio
const reactivarFolio = async () => {
  if (!modoReactivar.value) return

  showLoading('Reactivando folio...', 'Actualizando base de datos')

  try {
    const currentYear = new Date().getFullYear()
    // spd_13_abcdesctos - Operación 4 = Reactivar
    const response = await execute(
      'spd_13_abcdesctos',
      'cementerio',
      [
        { nombre: 'v_control', valor: folioSearch.value, tipo: 'integer' },
        { nombre: 'v_axo', valor: currentYear, tipo: 'integer' },
        { nombre: 'v_porc', valor: 0, tipo: 'integer' },
        { nombre: 'v_usu', valor: 1, tipo: 'integer' }, // TODO: Obtener de sesión
        { nombre: 'v_reac', valor: 'S', tipo: 'string' },
        { nombre: 'v_tipo_descto', valor: '', tipo: 'string' },
        { nombre: 'v_opc', valor: 4, tipo: 'integer' } // 4 = Reactivar
      ],
      'cementerio',
      null,
      'public'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]
      if (resultado.par_ok === 0) {
        showToast('success', resultado.par_observ || 'Folio reactivado correctamente')
        modoReactivar.value = false
        await cargarDescuentos()
      } else {
        showToast('error', resultado.par_observ || 'Error al reactivar folio')
      }
    } else {
      showToast('error', 'Error al reactivar folio')
    }
  } catch (error) {
    console.error('Error al reactivar folio:', error)
    showToast('error', 'Error al reactivar el folio')
  } finally {
    hideLoading()
  }
}

// Limpiar datos
const limpiarDatos = () => {
  folioData.value = null
  adeudos.value = []
  adeudoSeleccionado.value = null
  descuentoSeleccionado.value = null
  descuentosAplicados.value = []
  modoReactivar.value = false
}

// Calcular total de un adeudo
const calcularTotalAdeudo = (adeudo) => {
  const importe = parseFloat(adeudo.importe || 0)
  const recargos = parseFloat(adeudo.importe_recargos || 0)
  const descImporte = parseFloat(adeudo.descto_impote || 0)
  const descRecargos = parseFloat(adeudo.descto_recargos || 0)

  return importe + recargos - descImporte - descRecargos
}

// Formatear moneda
const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

// Formatear fecha
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}

// Métodos de paginación
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}
</script>
