<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Emisión de Recibos de Energía Eléctrica</h1>
        <p>Inicio > Operaciones > Emisión Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="ejecutarEmision" :disabled="loading || !canExecute">
          <font-awesome-icon icon="play" /> Ejecutar Emisión
        </button>
        <button class="btn-municipal-success" @click="grabarEmision" :disabled="loading || emision.length === 0">
          <font-awesome-icon icon="save" /> Grabar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
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
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedRecaudadora" @change="onRecaudadoraChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedMercado" :disabled="loading || !selectedRecaudadora">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="2003" max="2999" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="periodo" min="1" max="12" :disabled="loading" />
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
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Consumo</th>
                  <th>Cantidad</th>
                  <th class="text-end">Tarifa</th>
                  <th class="text-end">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in emision" :key="row.id_energia" class="row-hover">
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.cve_consumo }}</td>
                  <td class="text-end">{{ formatNumber(row.cantidad) }}</td>
                  <td class="text-end">{{ formatCurrency(row.importe) }}</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(row.importe_energia) }}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-else-if="!loading && searched" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No hay locales con energía para el periodo seleccionado</p>
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
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const recaudadoras = ref([])
const mercados = ref([])
const emision = ref([])
const selectedRecaudadora = ref('')
const selectedMercado = ref('')
const axo = ref(new Date().getFullYear())
const periodo = ref(new Date().getMonth() + 1)
const loading = ref(false)
const searched = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })

const canExecute = computed(() => selectedRecaudadora.value && selectedMercado.value && axo.value && periodo.value)

const totalEmision = computed(() => {
  return emision.value.reduce((sum, row) => sum + parseFloat(row.importe_energia || 0), 0)
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
  showToast('info', 'Seleccione recaudadora, mercado, año y periodo. Luego ejecute la emisión para ver los locales. Finalmente grabe la emisión.')
}

const fetchRecaudadoras = async () => {
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'padron_licencias', Parametros: [] }
    })
    if (res.data.eResponse.success) {
      recaudadoras.value = res.data.eResponse.data.result || []
    }
  } catch (err) {
    showToast('error', 'Error al cargar recaudadoras')
  } finally {
    loading.value = false
  }
}

const onRecaudadoraChange = async () => {
  selectedMercado.value = ''
  mercados.value = []
  if (!selectedRecaudadora.value) return
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_mercados', Base: 'padron_licencias', Parametros: [{ Nombre: 'p_oficina', Valor: parseInt(selectedRecaudadora.value) }] }
    })
    if (res.data.eResponse.success) {
      mercados.value = res.data.eResponse.data.result || []
    }
  } catch (err) {
    showToast('error', 'Error al cargar mercados')
  } finally {
    loading.value = false
  }
}

const ejecutarEmision = async () => {
  if (!canExecute.value) {
    showToast('warning', 'Complete todos los campos requeridos')
    return
  }
  loading.value = true
  emision.value = []
  searched.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'get_emision_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(selectedRecaudadora.value) },
          { Nombre: 'p_mercado', Valor: parseInt(selectedMercado.value) },
          { Nombre: 'p_axo', Valor: parseInt(axo.value) },
          { Nombre: 'p_periodo', Valor: parseInt(periodo.value) }
        ]
      }
    })
    if (res.data.eResponse.success) {
      emision.value = res.data.eResponse.data.result || []
      if (emision.value.length > 0) {
        showToast('success', `Emisión ejecutada: ${emision.value.length} locales encontrados`)
      } else {
        showToast('info', 'No hay locales con energía para este periodo')
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al ejecutar emisión')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al ejecutar emisión')
  } finally {
    loading.value = false
  }
}

const grabarEmision = async () => {
  if (emision.value.length === 0) {
    showToast('warning', 'No hay datos para grabar')
    return
  }
  if (!confirm('¿Está seguro de grabar la emisión de energía? Esta acción no se puede deshacer.')) {
    return
  }
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'grabar_emision_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(selectedRecaudadora.value) },
          { Nombre: 'p_mercado', Valor: parseInt(selectedMercado.value) },
          { Nombre: 'p_axo', Valor: parseInt(axo.value) },
          { Nombre: 'p_periodo', Valor: parseInt(periodo.value) },
          { Nombre: 'p_usuario', Valor: 1 }
        ]
      }
    })
    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result[0]
      if (result.status === 'ok') {
        showToast('success', result.message)
        emision.value = []
        searched.value = false
      } else {
        showToast('error', result.message)
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al grabar emisión')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al grabar emisión')
  } finally {
    loading.value = false
  }
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (val) => {
  if (val === null || val === undefined) return '0'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

onMounted(() => {
  fetchRecaudadoras()
})
</script>

<style scoped>
.empty-icon {
  color: #6c757d;
  opacity: 0.5;
  margin-bottom: 1rem;
}
</style>
