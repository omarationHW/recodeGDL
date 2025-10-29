<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Bajas</h1>
        <p>Otras Obligaciones - Dar de baja contratos</p>
      </div>
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda de Local</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Control:</label>
              <input type="text" v-model="formData.numero" class="municipal-form-control" placeholder="Número" maxlength="3" style="width: 120px; display: inline-block; margin-right: 10px;" />
              <span style="margin: 0 10px;">-</span>
              <input type="text" v-model="formData.letra" class="municipal-form-control" placeholder="Letra" maxlength="2" style="width: 100px; display: inline-block;" />
            </div>
            <div class="form-group">
              <button class="btn-municipal-primary" @click="handleBuscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="info-circle" /> Datos del Local</h5>
          <span class="badge" :class="datosLocal.cve_stat === 'V' ? 'badge-success' : 'badge-danger'">
            {{ datosLocal.descrip_stat }}
          </span>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Control:</strong>
              <span>{{ datosLocal.control }}</span>
            </div>
            <div class="info-item">
              <strong>Concesionario:</strong>
              <span>{{ datosLocal.concesionario }}</span>
            </div>
            <div class="info-item">
              <strong>Ubicación:</strong>
              <span>{{ datosLocal.ubicacion }}</span>
            </div>
            <div class="info-item">
              <strong>Superficie:</strong>
              <span>{{ datosLocal.superficie }}</span>
            </div>
            <div class="info-item">
              <strong>Licencia:</strong>
              <span>{{ datosLocal.licencia }}</span>
            </div>
            <div class="info-item">
              <strong>Sector:</strong>
              <span>{{ datosLocal.sector }}</span>
            </div>
            <div class="info-item">
              <strong>Zona:</strong>
              <span>{{ datosLocal.id_zona }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="datosLocal.control && datosLocal.cve_stat === 'V'">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar" /> Datos de Baja</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año de Baja:</label>
              <input type="number" v-model.number="formData.anioBaja" class="municipal-form-control" :min="2000" :max="2099" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mes de Baja:</label>
              <select v-model.number="formData.mesBaja" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <button class="btn-municipal-danger" @click="handleDarBaja" :disabled="loading">
              <font-awesome-icon icon="times-circle" /> Dar de Baja
            </button>
            <button class="btn-municipal-secondary" @click="handleCancelar" style="margin-left: 10px;">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="datosLocal.control && datosLocal.cve_stat !== 'V'">
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            Este local está en SUSPENSIÓN o CANCELADO, no se puede dar de baja
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Procesando...</p>
        </div>
      </div>
    </div>

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RBaja'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const router = useRouter()
const { callApi } = useApi()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const datosLocal = ref({})

const formData = reactive({
  numero: '',
  letra: '',
  anioBaja: new Date().getFullYear(),
  mesBaja: new Date().getMonth() + 1
})

const meses = [
  { value: 1, label: '01-Enero' },
  { value: 2, label: '02-Febrero' },
  { value: 3, label: '03-Marzo' },
  { value: 4, label: '04-Abril' },
  { value: 5, label: '05-Mayo' },
  { value: 6, label: '06-Junio' },
  { value: 7, label: '07-Julio' },
  { value: 8, label: '08-Agosto' },
  { value: 9, label: '09-Septiembre' },
  { value: 10, label: '10-Octubre' },
  { value: 11, label: '11-Noviembre' },
  { value: 12, label: '12-Diciembre' }
]

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  loading.value = true
  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    const response = await callApi('SP_RBAJA_BUSCAR', {
      p_control: control
    })

    if (response.data && response.data.length > 0) {
      datosLocal.value = response.data[0]
      showToast('success', 'Local encontrado')
    } else {
      showToast('warning', 'No se encontró el local')
      datosLocal.value = {}
    }
  } catch (error) {
    handleError(error, 'Error al buscar local')
  } finally {
    loading.value = false
  }
}

const handleDarBaja = async () => {
  if (!formData.anioBaja || !formData.mesBaja) {
    showToast('warning', 'Debe especificar año y mes de baja')
    return
  }

  loading.value = true
  try {
    const periodo = `${formData.anioBaja}-${String(formData.mesBaja).padStart(2, '0')}`
    const verificarResponse = await callApi('SP_RBAJA_VERIFICAR_ADEUDOS', {
      p_id_datos: datosLocal.value.id_34_datos,
      p_periodo: periodo
    })

    if (verificarResponse.data && verificarResponse.data[0].total_adeudos_vigentes > 0) {
      showToast('error', 'No es posible dar de baja. Tiene adeudos vigentes o posteriores')
      loading.value = false
      return
    }

    const result = await Swal.fire({
      title: 'Confirmación',
      text: '¿Está seguro de dar de BAJA este local?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Sí',
      cancelButtonText: 'No',
      confirmButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d'
    })

    if (result.isConfirmed) {
      const response = await callApi('SP_RBAJA_CANCELAR', {
        par_id_34_datos: datosLocal.value.id_34_datos,
        par_Axo_Fin: formData.anioBaja,
        par_Mes_Fin: formData.mesBaja
      })

      showToast('success', 'Baja realizada correctamente')
      handleCancelar()
    }

    loading.value = false
  } catch (error) {
    handleError(error, 'Error al dar de baja')
    loading.value = false
  }
}

const handleCancelar = () => {
  datosLocal.value = {}
  formData.numero = ''
  formData.letra = ''
  formData.anioBaja = new Date().getFullYear()
  formData.mesBaja = new Date().getMonth() + 1
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const goBack = () => {
  router.push('/otras_obligaciones')
}
</script>
