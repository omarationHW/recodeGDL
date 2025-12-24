<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cash-register" />
      </div>
      <div class="module-view-info">
        <h1>Emisión Libertad - Mercados con Caja de Cobro</h1>
        <p>Inicio > Operaciones > Emisión Libertad</p>
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
        
        <button class="btn-municipal-primary" @click="generarEmision" :disabled="loading || !canGenerate">
          <font-awesome-icon icon="play" /> Generar Emisión
        </button>
        <button class="btn-municipal-primary" @click="exportarTXT" :disabled="loading || emision.length === 0">
          <font-awesome-icon icon="file-download" /> Exportar TXT
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="sliders-h" /> Parámetros de Emisión</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="2003" max="2999" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="periodo" min="1" max="12" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedRecaudadora" @change="onRecaudadoraChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row" v-if="selectedRecaudadora">
            <div class="form-group full-width">
              <label class="municipal-form-label">Mercados <span class="required">*</span></label>
              <div class="mercados-grid">
                <div v-for="merc in mercados" :key="merc.num_mercado_nvo" class="mercado-checkbox">
                  <input type="checkbox" :id="'merc-' + merc.num_mercado_nvo" :value="merc.num_mercado_nvo"
                    v-model="selectedMercados" :disabled="loading" />
                  <label :for="'merc-' + merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="emision.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Detalle de Emisión</h5>
          <div class="header-right">
            <span class="badge-purple">{{ emision.length }} locales</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalEmision) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Mercado</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Descuento</th>
                  <th class="text-end">Adeudos</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Subtotal</th>
                  <th class="text-end">Multas</th>
                  <th class="text-end">Gastos</th>
                  <th>Folios Req.</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedEmision" :key="row.id_local" class="row-hover">
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatCurrency(row.renta) }}</td>
                  <td class="text-end">{{ formatCurrency(row.descuento) }}</td>
                  <td class="text-end">{{ formatCurrency(row.adeudos) }}</td>
                  <td class="text-end">{{ formatCurrency(row.recargos) }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.subtotal) }}</strong></td>
                  <td class="text-end">{{ formatCurrency(row.multas) }}</td>
                  <td class="text-end">{{ formatCurrency(row.gastos) }}</td>
                  <td>{{ row.folios }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-if="emision.length > 10" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </span>
            </div>
            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="!loading && searched" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No hay locales para los mercados seleccionados</p>
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

  <DocumentationModal :show="showAyuda" :component-name="'EmisionLibertad'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - EmisionLibertad'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'EmisionLibertad'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - EmisionLibertad'" @close="showDocumentacion = false" />
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
const emision = ref([])
const selectedRecaudadora = ref('')
const selectedMercados = ref([])
const axo = ref(new Date().getFullYear())
const periodo = ref(new Date().getMonth() + 1)
const loading = ref(false)
const searched = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })
const currentPage = ref(1)
const itemsPerPage = ref(10)

const canGenerate = computed(() => selectedRecaudadora.value && selectedMercados.value.length > 0 && axo.value && periodo.value)

const totalEmision = computed(() => {
  return emision.value.reduce((sum, row) => sum + parseFloat(row.subtotal || 0), 0)
})

const totalRecords = computed(() => emision.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedEmision = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return emision.value.slice(start, end)
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
  showToast('Seleccione año, periodo, recaudadora y uno o más mercados. Luego genere la emisión para crear recibos.', 'info')
}

const fetchRecaudadoras = async () => {
  showLoading('Cargando Emisión Libertad', 'Preparando oficinas recaudadoras...')
  loading.value = true
  try {
    const res = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      recaudadoras.value = res.data.result || []
    }
  } catch (err) {
    showToast('Error al cargar recaudadoras', 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const onRecaudadoraChange = async () => {
  console.log('onRecaudadoraChange.............')
  selectedMercados.value = []
  mercados.value = []
  if (!selectedRecaudadora.value) return
  loading.value = true
  try {
    const res = await apiService.execute(
      'sp_get_mercados_by_recaudadora',
      'mercados',
      [{ nombre: 'p_oficina', valor: parseInt(selectedRecaudadora.value), tipo: 'integer' }],
      '',
      null,
      'publico'
    )
    if (res.success) {
      mercados.value = res.data.result || []
    }
  } catch (err) {
    showToast('Error al cargar mercados', 'error')
  } finally {
    loading.value = false
  }
}

const generarEmision = async () => {
  if (!canGenerate.value) {
    showToast('Complete todos los campos y seleccione al menos un mercado', 'warning')
    return
  }
  loading.value = true
  emision.value = []
  searched.value = true
  currentPage.value = 1
  try {
    const res = await apiService.execute(
          'generar_emision_libertad',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(selectedRecaudadora.value) },
          { nombre: 'p_mercados', valor: JSON.stringify(selectedMercados.value) },
          { nombre: 'p_axo', valor: parseInt(axo.value) },
          { nombre: 'p_periodo', valor: parseInt(periodo.value) },
          { nombre: 'p_usuario_id', valor: 1 }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      emision.value = res.data.result || []
      if (emision.value.length > 0) {
        showToast(`Emisión generada: ${emision.value.length} locales`, 'success')
      } else {
        showToast('No hay locales para los mercados seleccionados', 'info')
      }
    } else {
      showToast(res.message || 'Error al generar emisión', 'error')
    }
  } catch (err) {
    showToast('Error de conexión al generar emisión', 'error')
  } finally {
    loading.value = false
  }
}

const exportarTXT = () => {
  if (emision.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  try {
    let txt = 'LOCAL|NOMBRE|MERCADO|RENTA|DESCUENTO|ADEUDOS|RECARGOS|SUBTOTAL|MULTAS|GASTOS|FOLIOS\n'
    emision.value.forEach(r => {
      txt += `${r.local}|${r.nombre}|${r.descripcion}|${r.renta}|${r.descuento}|${r.adeudos}|${r.recargos}|${r.subtotal}|${r.multas}|${r.gastos}|${r.folios}\n`
    })
    const blob = new Blob([txt], { type: 'text/plain;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `emision_libertad_${axo.value}_${periodo.value}.txt`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    showToast('Archivo exportado exitosamente', 'success')
  } catch (err) {
    showToast('Error al exportar', 'error')
  }
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

onMounted(() => {
  fetchRecaudadoras()
})
</script>
