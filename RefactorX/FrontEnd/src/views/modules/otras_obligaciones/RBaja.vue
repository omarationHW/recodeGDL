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
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda y documentación del módulo"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="isLoading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3 align-items-end">
            <div class="col-md-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" class="me-1" />
                Control:
              </label>
              <input
                type="text"
                v-model="formData.numero"
                class="municipal-form-control"
                placeholder="Número"
                maxlength="3"
              />
            </div>
            <div class="col-md-2">
              <label class="municipal-form-label">
                <font-awesome-icon icon="font" class="me-1" />
                Letra:
              </label>
              <input
                type="text"
                v-model="formData.letra"
                class="municipal-form-control"
                placeholder="Letra"
                maxlength="2"
              />
            </div>
            <div class="col-md-3">
              <button
                class="btn-municipal-primary w-100"
                @click="handleBuscar"
                :disabled="isLoading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos del Local
          </h5>
          <span
            class="badge"
            :class="datosLocal.cve_stat === 'V' ? 'badge-success' : 'badge-danger'"
          >
            {{ datosLocal.descrip_stat }}
          </span>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>
                <font-awesome-icon icon="hashtag" class="me-1" />
                Control:
              </label>
              <span>{{ datosLocal.control }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="user" class="me-1" />
                Concesionario:
              </label>
              <span>{{ datosLocal.concesionario }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="map-marker-alt" class="me-1" />
                Ubicación:
              </label>
              <span>{{ datosLocal.ubicacion }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="ruler-combined" class="me-1" />
                Superficie:
              </label>
              <span>{{ datosLocal.superficie }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="file-alt" class="me-1" />
                Licencia:
              </label>
              <span>{{ datosLocal.licencia }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="building" class="me-1" />
                Sector:
              </label>
              <span>{{ datosLocal.sector }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="map" class="me-1" />
                Zona:
              </label>
              <span>{{ datosLocal.id_zona }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="datosLocal.control && datosLocal.cve_stat === 'V'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calendar" />
            Datos de Baja
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-alt" class="me-1" />
                Año de Baja:
              </label>
              <input
                type="number"
                v-model.number="formData.anioBaja"
                class="municipal-form-control"
                :min="2000"
                :max="2099"
              />
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar" class="me-1" />
                Mes de Baja:
              </label>
              <select v-model.number="formData.mesBaja" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">
                  {{ mes.label }}
                </option>
              </select>
            </div>
          </div>
          <div class="d-flex gap-2 mt-4">
            <button
              class="btn-municipal-danger"
              @click="handleDarBaja"
              :disabled="isLoading"
            >
              <font-awesome-icon icon="times-circle" />
              Dar de Baja
            </button>
            <button
              class="btn-municipal-secondary"
              @click="handleCancelar"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="datosLocal.control && datosLocal.cve_stat !== 'V'">
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            Este local está en SUSPENSIÓN o CANCELADO, no se puede dar de baja
          </div>
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const router = useRouter()
const { execute } = useApi()
const { isLoading, startLoading, stopLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

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

  startLoading('Buscando local...')
  try {
    const response = await execute(
      'sp_rbaja_buscar_local',
      'otras_obligaciones',
      [
        { nombre: 'p_numero', valor: formData.numero, tipo: 'string' },
        { nombre: 'p_letra', valor: formData.letra || '', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      datosLocal.value = response.result[0]
      showToast('success', 'Local encontrado')
    } else {
      showToast('warning', 'No se encontró el local')
      datosLocal.value = {}
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    stopLoading()
  }
}

const handleDarBaja = async () => {
  if (!formData.anioBaja || !formData.mesBaja) {
    showToast('warning', 'Debe especificar año y mes de baja')
    return
  }

  startLoading('Verificando adeudos...')
  try {
    const periodo = `${formData.anioBaja}-${String(formData.mesBaja).padStart(2, '0')}`
    const verificarResponse = await execute(
      'sp_rbaja_verificar_adeudos_post',
      'otras_obligaciones',
      [
        { nombre: 'p_id_34_datos', valor: datosLocal.value.id_34_datos, tipo: 'integer' },
        { nombre: 'p_periodo', valor: periodo, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (verificarResponse && verificarResponse.result && verificarResponse.result.length > 0) {
      showToast('error', 'No es posible dar de baja. Tiene adeudos vigentes o posteriores')
      stopLoading()
      return
    }

    stopLoading()

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
      startLoading('Procesando baja...')
      const response = await execute(
        'sp_rbaja_cancelar_local',
        'otras_obligaciones',
        [
          { nombre: 'p_id_34_datos', valor: datosLocal.value.id_34_datos, tipo: 'integer' },
          { nombre: 'p_axo_fin', valor: formData.anioBaja, tipo: 'integer' },
          { nombre: 'p_mes_fin', valor: formData.mesBaja, tipo: 'integer' }
        ],
        'guadalajara'
      )

      if (response && response.result && response.result[0]?.codigo === 0) {
        showToast('success', 'Baja realizada correctamente')
        handleCancelar()
      } else {
        const mensaje = response?.result?.[0]?.mensaje || 'Error al dar de baja'
        showToast('error', mensaje)
      }
      stopLoading()
    }
  } catch (error) {
    handleApiError(error)
    stopLoading()
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
