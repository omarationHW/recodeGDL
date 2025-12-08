<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="hand-holding-dollar" /></div>
      <div class="module-view-info">
        <h1>Aplicar Pago — Diversos Admin</h1>
        <p>Búsqueda y aplicación de pagos administrativos</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="search" /> Búsqueda de Folios
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Búsqueda</label>
              <select class="municipal-form-control" v-model.number="opcion">
                <option :value="0">Por Placa</option>
                <option :value="1">Placa + Folio</option>
                <option :value="2">Año + Folio</option>
              </select>
            </div>
            <div class="form-group" v-if="opcion === 0 || opcion === 1">
              <label class="municipal-form-label">Placa *</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="placa"
                placeholder="ABC-123"
                @input="placa = placa.toUpperCase()"
              />
            </div>
            <div class="form-group" v-if="opcion === 1 || opcion === 2">
              <label class="municipal-form-label">Folio *</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="folio"
                placeholder="Número"
              />
            </div>
            <div class="form-group" v-if="opcion === 2">
              <label class="municipal-form-label">Año *</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="axo"
                :min="2000"
                :max="2100"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscar"
            >
              <font-awesome-icon icon="search" /> Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarBusqueda">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header d-flex justify-content-between">
          <span><font-awesome-icon icon="list" /> Resultados</span>
          <span class="badge bg-secondary">{{ resultados.length }} registros</span>
        </div>
        <div class="municipal-card-body">
          <div v-if="resultados.length === 0" class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="2x" class="mb-2" />
            <p>Realice una búsqueda para ver resultados</p>
          </div>

          <div v-else class="table-responsive">
            <table class="table table-striped table-hover">
              <thead class="table-dark">
                <tr>
                  <th>Año</th>
                  <th>Folio</th>
                  <th>Placa</th>
                  <th>Fecha Folio</th>
                  <th>Infracción</th>
                  <th>Tarifa</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedResultados" :key="`${r.axo}-${r.folio}`">
                  <td>{{ r.axo }}</td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.placa }}</td>
                  <td>{{ formatDate(r.fecha_folio) }}</td>
                  <td>{{ r.infraccion }}</td>
                  <td class="text-end">{{ formatMonto(r.tarifa) }}</td>
                  <td>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="seleccionarPago(r)"
                    >
                      <font-awesome-icon icon="check" /> Aplicar
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Paginación -->
            <div v-if="totalPages > 1" class="pagination-container">
              <button
                class="btn-municipal-secondary btn-sm"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-info">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-municipal-secondary btn-sm"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Parámetros de Pago -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <font-awesome-icon icon="credit-card" /> Parámetros de Pago
        </div>
        <div class="municipal-card-body">
          <div v-if="folioSeleccionado" class="alert alert-info mb-3">
            <strong>Folio seleccionado:</strong> {{ folioSeleccionado.axo }}-{{ folioSeleccionado.folio }} |
            Placa: {{ folioSeleccionado.placa }} |
            Tarifa: {{ formatMonto(folioSeleccionado.tarifa) }}
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Pago *</label>
              <input type="date" class="municipal-form-control" v-model="pago.fecha" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.reca" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Caja</label>
              <input type="text" class="municipal-form-control" v-model="pago.caja" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Operador</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.oper" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Usuario</label>
              <input type="text" class="municipal-form-control" v-model="pago.usuario" />
            </div>
          </div>

          <div class="button-group mt-3">
            <button
              class="btn-municipal-primary"
              :disabled="!folioSeleccionado"
              @click="aplicarPago"
            >
              <font-awesome-icon icon="dollar-sign" /> Aplicar Pago
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const opcion = ref(0)
const placa = ref('')
const folio = ref(null)
const axo = ref(new Date().getFullYear())
const resultados = ref([])
const folioSeleccionado = ref(null)

const pago = reactive({
  fecha: new Date().toISOString().split('T')[0],
  reca: null,
  caja: '',
  oper: null,
  usuario: ''
})

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const totalPages = computed(() => {
  return Math.ceil(resultados.value.length / itemsPerPage.value)
})

const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return resultados.value.slice(start, end)
})

watch(resultados, () => {
  currentPage.value = 1
})

function formatDate(d) {
  if (!d) return '-'
  return new Date(d).toLocaleDateString('es-MX')
}

function formatMonto(m) {
  if (!m) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(m)
}

function limpiarBusqueda() {
  placa.value = ''
  folio.value = null
  axo.value = new Date().getFullYear()
  resultados.value = []
  folioSeleccionado.value = null
}

async function buscar() {
  // Validar según opción
  if (opcion.value === 0 && !placa.value.trim()) {
    showToast('warning', 'Ingrese la placa a buscar')
    return
  }
  if (opcion.value === 1 && (!placa.value.trim() || !folio.value)) {
    showToast('warning', 'Ingrese placa y folio')
    return
  }
  if (opcion.value === 2 && (!axo.value || !folio.value)) {
    showToast('warning', 'Ingrese año y folio')
    return
  }

  showLoading('Buscando...', 'Consultando folios')
  resultados.value = []
  folioSeleccionado.value = null

  try {
    const params = [
      { nombre: 'p_opcion', valor: opcion.value, tipo: 'integer' },
      { nombre: 'p_placa', valor: placa.value.toUpperCase() || '', tipo: 'string' },
      { nombre: 'p_folio', valor: folio.value || 0, tipo: 'integer' },
      { nombre: 'p_axo', valor: axo.value || 0, tipo: 'integer' }
    ]

    const resp = await execute('sp_busca_folios_divadmin', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    resultados.value = Array.isArray(data) ? data : []

    hideLoading()

    if (resultados.value.length === 0) {
      showToast('info', 'No se encontraron folios con los criterios indicados')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  }
}

function seleccionarPago(r) {
  folioSeleccionado.value = r
  showToast('info', `Folio ${r.axo}-${r.folio} seleccionado para aplicar pago`)
}

async function aplicarPago() {
  if (!folioSeleccionado.value) {
    showToast('warning', 'Seleccione un folio de la lista')
    return
  }

  if (!pago.fecha) {
    showToast('warning', 'La fecha de pago es requerida')
    return
  }

  const r = folioSeleccionado.value
  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Pago',
    html: `
      <p>¿Aplicar pago al siguiente folio?</p>
      <ul class="swal-list-left">
        <li><strong>Año-Folio:</strong> ${r.axo}-${r.folio}</li>
        <li><strong>Placa:</strong> ${r.placa}</li>
        <li><strong>Tarifa:</strong> ${formatMonto(r.tarifa)}</li>
        <li><strong>Fecha Pago:</strong> ${pago.fecha}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, aplicar pago',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Procesando...', 'Aplicando pago')
  try {
    const params = [
      { nombre: 'p_axo', valor: r.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: r.folio, tipo: 'integer' },
      { nombre: 'p_fecha', valor: pago.fecha, tipo: 'date' },
      { nombre: 'p_reca', valor: pago.reca || 0, tipo: 'integer' },
      { nombre: 'p_caja', valor: pago.caja || '', tipo: 'string' },
      { nombre: 'p_oper', valor: pago.oper || 0, tipo: 'integer' },
      { nombre: 'p_usuario', valor: pago.usuario || '', tipo: 'string' }
    ]

    const resp = await execute('sp_aplica_pago_divadmin', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Pago Aplicado',
        text: data?.message || 'El pago se aplicó correctamente',
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
      // Remover de la lista
      resultados.value = resultados.value.filter(
        item => !(item.axo === r.axo && item.folio === r.folio)
      )
      folioSeleccionado.value = null
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo aplicar el pago'
      })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}
</script>
