<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="exchange-alt" />
      </div>
      <div class="module-view-info">
        <h1>Transferencia de Documentos</h1>
        <p>Inicio > Mercados > Transferencia de Documentos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Criterios de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onBuscar">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Elaboración <span class="required">*</span></label>
                <input
                  type="date"
                  v-model="form.fecha_elaboracion"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
                />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Cuenta <span class="required">*</span></label>
                <select
                  v-model="form.cuenta"
                  class="municipal-form-control"
                  @change="onCuentaChange"
                  :disabled="loading"
                >
                  <option v-for="cta in cuentas" :key="cta.id" :value="cta.id">
                    {{ cta.nombre }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Tipo de Documento <span class="required">*</span></label>
                <div class="radio-group">
                  <div class="form-check form-check-inline">
                    <input
                      class="form-check-input"
                      type="radio"
                      id="cheques"
                      value="C"
                      v-model="form.tipo_doc"
                      :disabled="loading"
                    />
                    <label class="form-check-label" for="cheques">Cheques</label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input
                      class="form-check-input"
                      type="radio"
                      id="pagador"
                      value="P"
                      v-model="form.tipo_doc"
                      :disabled="loading"
                    />
                    <label class="form-check-label" for="pagador">Elec. Bco. Pagador</label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input
                      class="form-check-input"
                      type="radio"
                      id="otros"
                      value="O"
                      v-model="form.tipo_doc"
                      :disabled="loading"
                    />
                    <label class="form-check-label" for="otros">Elec. Otros Bancos</label>
                  </div>
                </div>
              </div>
            </div>

            <!-- Botones de acción -->
            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button type="submit" class="btn-municipal-primary" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="documentos.length || buscado">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="file-alt" />
            Documentos Encontrados
          </h5>
          <div class="header-right">
            <span class="record-badge">{{ documentos.length }} registros</span>
          </div>
        </div>

        <div class="municipal-card-body">
          <div v-if="documentos.length" class="table-container">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Cheque</th>
                    <th>Fecha Elaboración</th>
                    <th>Importe</th>
                    <th>Ejercicio</th>
                    <th>Procedencia</th>
                    <th>Contrarecibo</th>
                    <th>Beneficiario</th>
                    <th>Forma de Pago</th>
                    <th>Cuenta</th>
                    <th>Proveedor</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="doc in documentos" :key="doc.id_ctrl_cheque">
                    <td>{{ doc.cheque }}</td>
                    <td>{{ doc.fecha_elaboracion }}</td>
                    <td class="text-end">{{ formatCurrency(doc.importe) }}</td>
                    <td>{{ doc.ejercicio }}</td>
                    <td>{{ doc.procedencia }}</td>
                    <td>{{ doc.contrarecibo }}</td>
                    <td>{{ doc.beneficiario }}</td>
                    <td>{{ doc.forma_pago }}</td>
                    <td>{{ doc.nombre }}</td>
                    <td>{{ doc.id_proveedor }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Botón de generar transferencia -->
            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button
                    class="btn-municipal-success"
                    @click="onGenerarTransferencia"
                    :disabled="loading"
                  >
                    <font-awesome-icon icon="file-download" />
                    Generar Archivo de Transferencia
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div v-else-if="buscado" class="empty-state">
            <font-awesome-icon icon="inbox" class="empty-icon" />
            <p>No se encontraron documentos para los criterios seleccionados.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para descarga -->
    <Modal
      :show="showModalDescarga"
      title="Archivo generado"
      size="md"
      @close="closeModalDescarga"
      :closable="true"
      :show-default-footer="false"
    >
      <div class="text-center py-3">
        <font-awesome-icon icon="check-circle" class="text-success" style="font-size: 3rem;" />
        <p class="mt-3 mb-3">El archivo de transferencia ha sido generado exitosamente.</p>
        <a
          :href="archivoUrl"
          download
          class="btn-municipal-primary"
          @click="closeModalDescarga"
        >
          <font-awesome-icon icon="download" />
          Descargar archivo
        </a>
      </div>
    </Modal>

    <!-- Toast Notifications -->
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
import { ref, onMounted } from 'vue'
import axios from 'axios'
import Modal from '@/components/common/Modal.vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast: showToastComposable } = useToast()

// Estado
const form = ref({
  fecha_elaboracion: '',
  cuenta: '',
  tipo_doc: 'C',
})

const cuentas = ref([])
const documentos = ref([])
const bancos = ref([])
const archivoUrl = ref('')
const buscado = ref(false)
const loading = ref(false)
const showModalDescarga = ref(false)

// Toast local (para mostrar en UI)
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Métodos de Toast
const showToast = (type, message) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Métodos del componente
const mostrarAyuda = () => {
  showToast('info', 'Seleccione una fecha, cuenta y tipo de documento para buscar los documentos a transferir')
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const loadCuentas = async () => {
  showLoading('Cargando cuentas...', 'Por favor espere')
  loading.value = true
  try {
    // Simulación: en real, pedir a API
    // Aquí se asume que el usuario tiene acceso a ciertas cuentas
    // En producción, pedir a /api/execute con getCuentasTrans
    cuentas.value = [
      { id: 1, nombre: 'Cuenta 1', moneda: 1, cta_mayor: 1102, cta_sub01: 3, cta_sub02: 1, cta_sub03: 7 },
      // ...
    ]

    if (cuentas.value.length > 0) {
      form.value.cuenta = cuentas.value[0].id
    }
  } catch (error) {
    console.error('Error al cargar cuentas:', error)
    showToast('error', 'Error al cargar las cuentas')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const loadBancos = async () => {
  showLoading('Cargando bancos...', 'Por favor espere')
  loading.value = true
  try {
    // Simulación: en real, pedir a API
    bancos.value = [
      { banco: 1, nombre: 'Banco 1', pagador: 'S' },
      // ...
    ]
  } catch (error) {
    console.error('Error al cargar bancos:', error)
    showToast('error', 'Error al cargar los bancos')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const onCuentaChange = () => {
  // Si se requiere cargar info adicional de la cuenta
}

const onBuscar = async () => {
  showLoading('Buscando documentos...', 'Por favor espere')
  loading.value = true
  buscado.value = false

  try {
    const cuenta = cuentas.value.find(c => c.id === form.value.cuenta)

    if (!cuenta) {
      showToast('warning', 'Debe seleccionar una cuenta válida')
      return
    }

    let params = {
      fecha_elaboracion: form.value.fecha_elaboracion,
      moneda: cuenta.moneda,
      cta_mayor: cuenta.cta_mayor,
      cta_sub01: cuenta.cta_sub01,
      cta_sub02: cuenta.cta_sub02,
      cta_sub03: cuenta.cta_sub03,
      forma_pago: form.value.tipo_doc,
      banco: form.value.tipo_doc === 'P' ? bancos.value[0]?.banco : null
    }

    const { data } = await axios.post('/api/execute', {
      eRequest: {
        operation: 'getDocumentos',
        params
      }
    })

    documentos.value = data.eResponse.data || []
    buscado.value = true

    if (documentos.value.length > 0) {
      showToast('success', `Se encontraron ${documentos.value.length} documentos`)
    } else {
      showToast('info', 'No se encontraron documentos para los criterios seleccionados')
    }
  } catch (error) {
    console.error('Error al buscar documentos:', error)
    showToast('error', 'Error al buscar documentos')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const onGenerarTransferencia = async () => {
  if (!documentos.value.length) {
    showToast('warning', 'No hay documentos para generar la transferencia')
    return
  }

  showLoading('Generando archivo de transferencia...', 'Por favor espere')
  loading.value = true

  try {
    const cuenta = cuentas.value.find(c => c.id === form.value.cuenta)

    let params = {
      tipo_doc: form.value.tipo_doc,
      fecha: form.value.fecha_elaboracion,
      moneda: cuenta.moneda,
      cta_mayor: cuenta.cta_mayor,
      cta_sub01: cuenta.cta_sub01,
      cta_sub02: cuenta.cta_sub02,
      documentos: documentos.value
    }

    const { data } = await axios.post('/api/execute', {
      eRequest: {
        operation: 'generarTransferencia',
        params
      }
    })

    if (data.eResponse.success && data.eResponse.data && data.eResponse.data[0].archivo_url) {
      archivoUrl.value = data.eResponse.data[0].archivo_url
      showModalDescarga.value = true
      showToast('success', 'Archivo generado exitosamente')
    } else {
      showToast('error', 'No se pudo generar el archivo')
    }
  } catch (error) {
    console.error('Error al generar archivo de transferencia:', error)
    showToast('error', 'Error al generar archivo de transferencia')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const closeModalDescarga = () => {
  showModalDescarga.value = false
}

// Lifecycle
onMounted(() => {
  form.value.fecha_elaboracion = new Date().toISOString().substr(0, 10)
  loadCuentas()
  loadBancos()
})
</script>
