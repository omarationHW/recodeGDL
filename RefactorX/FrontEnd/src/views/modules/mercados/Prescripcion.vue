<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hourglass-end" />
      </div>
      <div class="module-view-info">
        <h1>Prescripción de Adeudos de Energía</h1>
        <p>Mercados > Prescripción de Adeudos de Energía Eléctrica</p>
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
        
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda de local -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.oficina" @change="onOficinaChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.mercado" @change="onMercadoChange"
                :disabled="loading || !form.oficina">
                <option value="">Seleccione...</option>
                <option v-for="m in mercadosFiltrados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Categoría <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.categoria" placeholder="Categoría"
                :disabled="loading || !form.mercado" min="1" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Sección <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.seccion" :disabled="loading || !form.mercado">
                <option value="">Seleccione...</option>
                <option v-for="s in secciones" :key="s.seccion" :value="s.seccion">
                  {{ s.seccion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Local <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.local" placeholder="Local"
                :disabled="loading" min="1" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="form.letra_local" placeholder="Letra"
                maxlength="2" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="form.bloque" placeholder="Bloque" maxlength="2"
                :disabled="loading" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary" @click="buscarLocal" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar Local
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Información del local encontrado -->
      <div v-if="localEncontrado" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="store" />
            Información del Local
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6">
              <p><strong>Nombre:</strong> {{ localEncontrado.nombre || 'N/A' }}</p>
              <p><strong>Superficie:</strong> {{ localEncontrado.superficie || 'N/A' }} m²</p>
            </div>
            <div class="col-md-6">
              <p><strong>Giro:</strong> {{ localEncontrado.giro || 'N/A' }}</p>
              <p><strong>Clave Cuota:</strong> {{ localEncontrado.clave_cuota || 'N/A' }}</p>
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-md-4">
              <label class="municipal-form-label">Número de Oficio <span class="required">*</span></label>
              <input type="text" class="municipal-form-control" v-model="numeroOficio" placeholder="Número de oficio"
                maxlength="50" />
            </div>
          </div>
        </div>
      </div>

      <!-- Grids de Adeudos y Prescripciones -->
      <div v-if="localEncontrado" class="row">
        <!-- Grid de Adeudos Pendientes -->
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header header-with-badge">
              <h5>
                <font-awesome-icon icon="file-invoice-dollar" />
                Adeudos de Energía Pendientes
              </h5>
              <div class="header-right">
                <span class="badge-purple" v-if="adeudosPendientes.length > 0">
                  {{ adeudosPendientes.length }} adeudos
                </span>
              </div>
            </div>

            <div class="municipal-card-body">
              <div v-if="loadingAdeudos" class="text-center py-3">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Cargando...</span>
                </div>
              </div>

              <div v-else class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Año</th>
                      <th>Mes</th>
                      <th>Consumo</th>
                      <th>Cantidad</th>
                      <th>Importe</th>
                      <th>Sel</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="adeudosPendientes.length === 0">
                      <td colspan="6" class="text-center text-muted">
                        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                        <p>No hay adeudos pendientes</p>
                      </td>
                    </tr>
                    <tr v-else v-for="adeudo in adeudosPendientes" :key="adeudo.id_adeudo_energia">
                      <td>{{ adeudo.axo }}</td>
                      <td>{{ adeudo.periodo }}</td>
                      <td>{{ adeudo.cve_consumo }}</td>
                      <td>{{ adeudo.cantidad }}</td>
                      <td class="text-end">{{ formatCurrency(adeudo.importe) }}</td>
                      <td class="text-center">
                        <input type="checkbox" v-model="adeudosSeleccionados" :value="adeudo" />
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div v-if="adeudosPendientes.length > 0" class="text-end mt-3">
                <button class="btn-municipal-danger" @click="prescribirSeleccionados"
                  :disabled="adeudosSeleccionados.length === 0 || !numeroOficio || loading">
                  <font-awesome-icon icon="ban" />
                  Prescribir Seleccionados ({{ adeudosSeleccionados.length }})
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Grid de Adeudos Prescritos -->
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header header-with-badge">
              <h5>
                <font-awesome-icon icon="check-circle" />
                Adeudos Prescritos/Condonados
              </h5>
              <div class="header-right">
                <span class="badge-success" v-if="adeudosPrescritos.length > 0">
                  {{ adeudosPrescritos.length }} prescritos
                </span>
              </div>
            </div>

            <div class="municipal-card-body">
              <div v-if="loadingPrescritos" class="text-center py-3">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Cargando...</span>
                </div>
              </div>

              <div v-else class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Año</th>
                      <th>Mes</th>
                      <th>Consumo</th>
                      <th>Cantidad</th>
                      <th>Importe</th>
                      <th>Sel</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="adeudosPrescritos.length === 0">
                      <td colspan="6" class="text-center text-muted">
                        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                        <p>No hay adeudos prescritos</p>
                      </td>
                    </tr>
                    <tr v-else v-for="adeudo in adeudosPrescritos" :key="adeudo.id_cancelacion">
                      <td>{{ adeudo.axo }}</td>
                      <td>{{ adeudo.periodo }}</td>
                      <td>{{ adeudo.cve_consumo }}</td>
                      <td>{{ adeudo.cantidad }}</td>
                      <td class="text-end">{{ formatCurrency(adeudo.importe) }}</td>
                      <td class="text-center">
                        <input type="checkbox" v-model="prescritosSeleccionados" :value="adeudo" />
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div v-if="adeudosPrescritos.length > 0" class="text-end mt-3">
                <button class="btn-municipal-warning" @click="quitarPrescripcionSeleccionados"
                  :disabled="prescritosSeleccionados.length === 0 || loading">
                  <font-awesome-icon icon="undo" />
                  Quitar Prescripción ({{ prescritosSeleccionados.length }})
                </button>
              </div>
            </div>
          </div>
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
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'Prescripcion'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - Prescripcion'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'Prescripcion'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - Prescripcion'" @close="showDocumentacion = false" />
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

// Estado
const loading = ref(false)
const loadingAdeudos = ref(false)
const loadingPrescritos = ref(false)
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const form = ref({
  oficina: '',
  mercado: '',
  categoria: 1,
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
})
const localEncontrado = ref(null)
const numeroOficio = ref('')
const adeudosPendientes = ref([])
const adeudosPrescritos = ref([])
const adeudosSeleccionados = ref([])
const prescritosSeleccionados = ref([])

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Computed
const mercadosFiltrados = computed(() => {
  if (!form.value.oficina) return []
  return mercados.value.filter(m => m.oficina === form.value.oficina)
})

// Métodos
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

const mostrarAyuda = () => {
  showToast('Complete los datos del local para buscar sus adeudos de energía y proceder con la prescripción', 'info')
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const fetchRecaudadoras = async () => {
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
    console.error('Error al cargar recaudadoras:', err)
  }
}

const fetchMercados = async () => {
  try {
    const res = await apiService.execute(
          'sp_reporte_catalogo_mercados',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      mercados.value = res.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar mercados:', err)
  }
}

const fetchSecciones = async () => {
  try {
    const res = await apiService.execute(
          'sp_get_secciones',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      secciones.value = res.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar secciones:', err)
  }
}

const onOficinaChange = () => {
  form.value.mercado = ''
  form.value.seccion = ''
  form.value.local = ''
  localEncontrado.value = null
}

const onMercadoChange = () => {
  form.value.seccion = ''
  form.value.local = ''
  localEncontrado.value = null
}

const buscarLocal = async () => {
  if (!form.value.oficina || !form.value.mercado || !form.value.categoria || !form.value.seccion || !form.value.local) {
    showToast('Complete los campos requeridos para buscar el local', 'warning')
    return
  }

  loading.value = true
  localEncontrado.value = null
  adeudosPendientes.value = []
  adeudosPrescritos.value = []
  adeudosSeleccionados.value = []
  prescritosSeleccionados.value = []

  try {
    const res = await apiService.execute(
          'sp_localesmodif_buscar_local',
          'mercados',
          [
          { nombre: 'p_oficina', valor: form.value.oficina, tipo: 'integer' },
          { nombre: 'p_num_mercado', valor: form.value.mercado, tipo: 'integer' },
          { nombre: 'p_categoria', valor: form.value.categoria, tipo: 'integer' },
          { nombre: 'p_seccion', valor: form.value.seccion, tipo: 'string' },
          { nombre: 'p_local', valor: form.value.local, tipo: 'integer' },
          { nombre: 'p_letra_local', valor: form.value.letra_local || null, tipo: 'string' },
          { nombre: 'p_bloque', valor: form.value.bloque || null, tipo: 'string' }
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      const result = res.data.result || []
      if (result.length > 0) {
        localEncontrado.value = result[0]
        showToast('Local encontrado', 'success')
        await cargarAdeudos()
      } else {
        showToast('No se encontró el local con los datos especificados', 'warning')
      }
    } else {
      showToast(res.message || 'Error al buscar local', 'error')
    }
  } catch (err) {
    console.error('Error al buscar local:', err)
    showToast('Error de conexión al buscar local', 'error')
  } finally {
    loading.value = false
  }
}

const cargarAdeudos = async () => {
  if (!localEncontrado.value || !localEncontrado.value.id_energia) return

  loadingAdeudos.value = true
  loadingPrescritos.value = true

  try {
    // Cargar adeudos pendientes
    const resAdeudos = await apiService.execute(
          'sp_listar_adeudos_energia',
          'mercados',
          [
          { nombre: 'p_id_energia', valor: localEncontrado.value.id_energia, tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        )

    if (resAdeudos.success) {
      adeudosPendientes.value = resAdeudos.data.result || []
    }

    // Cargar adeudos prescritos
    const resPrescritos = await apiService.execute(
          'sp_listar_prescripciones',
          'mercados',
          [
          { nombre: 'p_id_energia', valor: localEncontrado.value.id_energia, tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        )

    if (resPrescritos.success) {
      adeudosPrescritos.value = resPrescritos.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar adeudos:', err)
    showToast('Error al cargar adeudos del local', 'error')
  } finally {
    loadingAdeudos.value = false
    loadingPrescritos.value = false
  }
}

const prescribirSeleccionados = async () => {
  if (adeudosSeleccionados.value.length === 0) {
    showToast('Seleccione al menos un adeudo para prescribir', 'warning')
    return
  }

  if (!numeroOficio.value.trim()) {
    showToast('Debe ingresar el número de oficio', 'warning')
    return
  }

  loading.value = true

  try {
    for (const adeudo of adeudosSeleccionados.value) {
      await apiService.execute(
          'sp_prescribir_adeudo',
          'mercados',
          [
            { nombre: 'p_id_energia', valor: localEncontrado.value.id_energia, tipo: 'integer' },
            { nombre: 'p_axo', valor: adeudo.axo, tipo: 'smallint' },
            { nombre: 'p_periodo', valor: adeudo.periodo, tipo: 'smallint' },
            { nombre: 'p_cve_consumo', valor: adeudo.cve_consumo, tipo: 'string' },
            { nombre: 'p_cantidad', valor: adeudo.cantidad, tipo: 'numeric' },
            { nombre: 'p_importe', valor: adeudo.importe, tipo: 'numeric' },
            { nombre: 'p_clave_canc', valor: numeroOficio.value, tipo: 'string' },
            { nombre: 'p_observacion', valor: 'Prescripción de adeudo', tipo: 'string' },
            { nombre: 'p_id_usuario', valor: 1, tipo: 'integer' }
          ],
          '',
          null,
          'publico'
        )
    }

    showToast(`Se prescribieron ${adeudosSeleccionados.value.length} adeudo(s) exitosamente`, 'success')
    adeudosSeleccionados.value = []
    await cargarAdeudos()
  } catch (err) {
    console.error('Error al prescribir adeudos:', err)
    showToast('Error al prescribir adeudos', 'error')
  } finally {
    loading.value = false
  }
}

const quitarPrescripcionSeleccionados = async () => {
  if (prescritosSeleccionados.value.length === 0) {
    showToast('Seleccione al menos una prescripción para quitar', 'warning')
    return
  }

  loading.value = true

  try {
    for (const prescrito of prescritosSeleccionados.value) {
      await apiService.execute(
          'sp_quitar_prescripcion',
          'mercados',
          [
            { nombre: 'p_id_energia', valor: localEncontrado.value.id_energia, tipo: 'integer' },
            { nombre: 'p_axo', valor: prescrito.axo, tipo: 'smallint' },
            { nombre: 'p_periodo', valor: prescrito.periodo, tipo: 'smallint' },
            { nombre: 'p_cve_consumo', valor: prescrito.cve_consumo, tipo: 'string' },
            { nombre: 'p_cantidad', valor: prescrito.cantidad, tipo: 'numeric' },
            { nombre: 'p_importe', valor: prescrito.importe, tipo: 'numeric' },
            { nombre: 'p_id_usuario', valor: 1, tipo: 'integer' },
            { nombre: 'p_id_cancelacion', valor: prescrito.id_cancelacion, tipo: 'integer' }
          ],
          '',
          null,
          'publico'
        )
    }

    showToast(`Se quitaron ${prescritosSeleccionados.value.length} prescripción(es) exitosamente`, 'success')
    prescritosSeleccionados.value = []
    await cargarAdeudos()
  } catch (err) {
    console.error('Error al quitar prescripción:', err)
    showToast('Error al quitar prescripción', 'error')
  } finally {
    loading.value = false
  }
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando Prescripción', 'Preparando catálogos...')
  try {
    await Promise.all([fetchRecaudadoras(), fetchMercados(), fetchSecciones()])
  } finally {
    hideLoading()
  }
})
</script>
