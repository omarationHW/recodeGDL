<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Ingresos Capturados</h1>
        <p>Inicio > Consultas > Ingreso Captura</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="buscar" :disabled="loading || !isFormValid">
          <font-awesome-icon icon="search" /> Buscar
        </button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="form.oficina_pago" @change="onOficinaChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="form.num_mercado" :disabled="loading || !form.oficina_pago">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Pago <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_pago" :disabled="loading" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Caja de Pago <span class="required">*</span></label>
              <input type="text" class="municipal-form-control" v-model="form.caja_pago"
                     maxlength="3" :disabled="loading" placeholder="Ej: A" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Operación de Pago <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.operacion_pago"
                     min="1" :disabled="loading" placeholder="Ej: 100" />
            </div>
          </div>
        </div>
      </div>

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Resumen de Ingresos Capturados</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} registros</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span>
            <span class="badge-info ms-2">Pagos: {{ totalPagos }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th class="text-center">Fecha de Pago</th>
                  <th class="text-center">Caja</th>
                  <th class="text-center">Operación</th>
                  <th class="text-end">Periodos/Pagos</th>
                  <th class="text-end">Renta Pagada</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in results" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td class="text-center">{{ formatDate(row.fecha_pago) }}</td>
                  <td class="text-center"><span class="badge-primary">{{ row.caja_pago }}</span></td>
                  <td class="text-center"><strong class="text-primary">{{ row.operacion_pago }}</strong></td>
                  <td class="text-end"><span class="badge-info">{{ row.pagos }}</span></td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="4" class="text-end"><strong>TOTALES:</strong></td>
                  <td class="text-end"><strong class="text-primary">{{ totalPagos }}</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div v-else-if="searched && !loading" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No hay resultados para los filtros seleccionados</p>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'IngresoCaptura'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - IngresoCaptura'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'IngresoCaptura'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - IngresoCaptura'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()

const recaudadoras = ref([])
const mercados = ref([])
const form = ref({
  num_mercado: null,
  fecha_pago: '',
  oficina_pago: null,
  caja_pago: '',
  operacion_pago: null
})

const results = ref([])
const loading = ref(false)
const searched = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })

const isFormValid = computed(() => {
  return form.value.num_mercado && form.value.fecha_pago &&
         form.value.oficina_pago && form.value.caja_pago &&
         form.value.operacion_pago
})

const totalImporte = computed(() => {
  return results.value.reduce((sum, row) => sum + parseFloat(row.importe || 0), 0)
})

const totalPagos = computed(() => {
  return results.value.reduce((sum, row) => sum + parseInt(row.pagos || 0), 0)
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('Complete todos los filtros (mercado, fecha, oficina, caja y operación) para consultar los ingresos capturados en ese periodo.', 'info')
}

const fetchRecaudadoras = async () => {
  showLoading('Cargando Oficinas Recaudadoras', 'Preparando catálogos del sistema...')
  try {
    const res = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res?.success) recaudadoras.value = res.data.result || []
  } catch (err) {
    showToast('Error al cargar recaudadoras', 'error')
  } finally {
    hideLoading()
  }
}

const onOficinaChange = async () => {
  mercados.value = []
  form.value.num_mercado = null
  if (!form.value.oficina_pago) return
  try {
    const res = await apiService.execute(
          'sp_consulta_locales_get_mercados',
          'mercados',
          [{ nombre: 'p_oficina', valor: form.value.oficina_pago }],
          '',
          null,
          'publico'
        )
    if (res?.success) mercados.value = res.data.result || []
  } catch (err) {
    showToast('Error al cargar mercados', 'error')
  }
}

const buscar = async () => {
  if (!isFormValid.value) {
    showToast('Complete todos los campos requeridos', 'warning')
    return
  }

  loading.value = true
  results.value = []
  searched.value = true

  showLoading()
  try {
    const res = await apiService.execute(
          'sp_get_ingreso_captura',
          'mercados',
          [
          { nombre: 'p_num_mercado', valor: parseInt(form.value.num_mercado) },
          { nombre: 'p_fecha_pago', valor: form.value.fecha_pago },
          { nombre: 'p_oficina_pago', valor: parseInt(form.value.oficina_pago) },
          { nombre: 'p_caja_pago', valor: form.value.caja_pago.toUpperCase() },
          { nombre: 'p_operacion_pago', valor: parseInt(form.value.operacion_pago) }
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      results.value = res.data.result || []
      if (results.value.length > 0) {
        showToast(`Se encontraron ${results.value.length} registros`, 'success')
      } else {
        showToast('No se encontraron resultados para los filtros aplicados', 'info')
      }
    } else {
      showToast(res.message || 'Error al consultar', 'error')
    }
  } catch (err) {
    showToast('Error de conexión al realizar la consulta', 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const exportarExcel = () => {
  if (results.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  try {
    let csv = 'Fecha de Pago,Caja,Operación,Periodos/Pagos,Renta Pagada\n'
    results.value.forEach(row => {
      csv += `${formatDate(row.fecha_pago)},${row.caja_pago},${row.operacion_pago},${row.pagos},${row.importe}\n`
    })
    csv += `,,TOTALES,${totalPagos.value},${totalImporte.value}\n`

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `ingreso_captura_${form.value.num_mercado}_${form.value.fecha_pago}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)

    showToast('Archivo exportado exitosamente', 'success')
  } catch (err) {
    showToast('Error al exportar', 'error')
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr + 'T00:00:00')
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

onMounted(() => {
  fetchRecaudadoras()
})
</script>
