<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="link" />
      </div>
      <div class="module-view-info">
        <h1>Liga de Anuncios</h1>
        <p>Padrón de Licencias - Ligar/Desligar Anuncios a Licencias o Empresas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Paso 1: Búsqueda de Anuncio -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Paso 1: Buscar Anuncio
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Anuncio: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.anuncioId"
              placeholder="Ingrese el número de anuncio"
            >
          </div>
          <div class="form-group align-end">
            <button
              class="btn-municipal-primary"
              @click="buscarAnuncio"
              :disabled="!searchForm.anuncioId"
            >
              <font-awesome-icon icon="search" />
              Buscar Anuncio
            </button>
          </div>
        </div>

        <!-- Información del anuncio encontrado -->
        <div v-if="anuncioEncontrado" class="info-box info-success">
          <h6>
            <font-awesome-icon icon="check-circle" />
            Anuncio Encontrado
          </h6>
          <div class="info-grid">
            <div class="info-item">
              <strong>ID Anuncio:</strong>
              <span>{{ anuncioEncontrado.id_anuncio }}</span>
            </div>
            <div class="info-item">
              <strong>Número:</strong>
              <span>{{ anuncioEncontrado.anuncio }}</span>
            </div>
            <div class="info-item">
              <strong>Estado:</strong>
              <span class="badge" :class="anuncioEncontrado.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                {{ anuncioEncontrado.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
              </span>
            </div>
            <div class="info-item">
              <strong>Licencia Actual:</strong>
              <span>{{ anuncioEncontrado.id_licencia || 'Sin ligar' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 2: Selección de tipo -->
    <div class="municipal-card" v-if="anuncioEncontrado">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="tasks" />
          Paso 2: Seleccionar Tipo de Liga
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-group">
          <label class="municipal-form-label">¿A qué desea ligar el anuncio?</label>
          <div class="radio-group">
            <label class="radio-option">
              <input
                type="radio"
                v-model="ligaType"
                value="licencia"
              >
              <span>Licencia</span>
            </label>
            <label class="radio-option">
              <input
                type="radio"
                v-model="ligaType"
                value="empresa"
              >
              <span>Empresa</span>
            </label>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 3: Búsqueda de Licencia o Empresa -->
    <div class="municipal-card" v-if="anuncioEncontrado && ligaType">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Paso 3: Buscar {{ ligaType === 'licencia' ? 'Licencia' : 'Empresa' }}
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">
              Número de {{ ligaType === 'licencia' ? 'Licencia' : 'Empresa' }}: <span class="required">*</span>
            </label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.targetId"
              :placeholder="`Ingrese el número de ${ligaType}`"
            >
          </div>
          <div class="form-group align-end">
            <button
              class="btn-municipal-primary"
              @click="buscarTarget"
              :disabled="!searchForm.targetId"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>

        <!-- Información del target encontrado -->
        <div v-if="targetEncontrado" class="info-box info-primary">
          <h6>
            <font-awesome-icon icon="check-circle" />
            {{ ligaType === 'licencia' ? 'Licencia' : 'Empresa' }} Encontrada
          </h6>
          <div class="info-grid">
            <div class="info-item">
              <strong>ID:</strong>
              <span>{{ targetEncontrado.id_licencia }}</span>
            </div>
            <div class="info-item">
              <strong>{{ ligaType === 'licencia' ? 'Licencia' : 'Empresa' }}:</strong>
              <span>{{ ligaType === 'licencia' ? targetEncontrado.licencia : targetEncontrado.empresa }}</span>
            </div>
            <div class="info-item">
              <strong>Estado:</strong>
              <span class="badge" :class="targetEncontrado.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                {{ targetEncontrado.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
              </span>
            </div>
            <div class="info-item" v-if="targetEncontrado.ubicacion">
              <strong>Ubicación:</strong>
              <span>{{ targetEncontrado.ubicacion }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 4: Confirmación y Liga -->
    <div class="municipal-card" v-if="anuncioEncontrado && targetEncontrado">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="link" />
          Paso 4: Confirmar y Ligar
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="confirmation-box">
          <div class="confirmation-icon">
            <font-awesome-icon icon="question-circle" size="3x" />
          </div>
          <div class="confirmation-content">
            <h4>¿Confirmar liga de anuncio?</h4>
            <p>Se ligará el siguiente anuncio:</p>
            <ul class="confirmation-list">
              <li><strong>Anuncio:</strong> {{ anuncioEncontrado.anuncio }} (ID: {{ anuncioEncontrado.id_anuncio }})</li>
              <li><strong>{{ ligaType === 'licencia' ? 'Licencia' : 'Empresa' }}:</strong>
                {{ ligaType === 'licencia' ? targetEncontrado.licencia : targetEncontrado.empresa }}
                (ID: {{ targetEncontrado.id_licencia }})
              </li>
            </ul>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="ligarAnuncio"
          >
            <font-awesome-icon icon="link" />
            Ligar Anuncio
          </button>
          <button
            class="btn-municipal-secondary"
            @click="resetForm"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ligaAnunciofrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Liga de Anuncios'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const searchForm = ref({
  anuncioId: null,
  targetId: null
})

const ligaType = ref('') // 'licencia' o 'empresa'
const anuncioEncontrado = ref(null)
const targetEncontrado = ref(null)
const hasSearched = ref(false)

// Métodos
const buscarAnuncio = async () => {
  if (!searchForm.value.anuncioId) {
    await Swal.fire({
      icon: 'warning',
      title: 'Número requerido',
      text: 'Por favor ingrese el número de anuncio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Buscando anuncio...', 'Consultando base de datos')
  hasSearched.value = true

  try {
    const response = await execute(
      'sp_buscar_anuncio',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchForm.value.anuncioId, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      anuncioEncontrado.value = response.result[0]
      showToast('success', 'Anuncio encontrado')

      if (anuncioEncontrado.value.vigente !== 'V') {
        await Swal.fire({
          icon: 'warning',
          title: 'Anuncio Cancelado',
          text: 'Este anuncio está cancelado. No se puede ligar.',
          confirmButtonColor: '#ea8215'
        })
      }
    } else {
      anuncioEncontrado.value = null
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No se encontró ningún anuncio con ese número',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    anuncioEncontrado.value = null
  } finally {
    hideLoading()
  }
}

const buscarTarget = async () => {
  if (!searchForm.value.targetId) {
    await Swal.fire({
      icon: 'warning',
      title: 'Número requerido',
      text: `Por favor ingrese el número de ${ligaType.value}`,
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading(`Buscando ${ligaType.value}...`, 'Consultando base de datos')

  try {
    const spName = ligaType.value === 'licencia' ? 'sp_buscar_licencia' : 'sp_buscar_empresa'
    const paramName = ligaType.value === 'licencia' ? 'p_licencia' : 'p_empresa'

    const response = await execute(
      spName,
      'padron_licencias',
      [
        { nombre: paramName, valor: searchForm.value.targetId, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      targetEncontrado.value = response.result[0]
      showToast('success', `${ligaType.value === 'licencia' ? 'Licencia' : 'Empresa'} encontrada`)

      if (targetEncontrado.value.vigente !== 'V') {
        await Swal.fire({
          icon: 'warning',
          title: 'Registro Cancelado',
          text: `Esta ${ligaType.value} está cancelada. No se puede ligar.`,
          confirmButtonColor: '#ea8215'
        })
      }
    } else {
      targetEncontrado.value = null
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: `No se encontró ninguna ${ligaType.value} con ese número`,
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    targetEncontrado.value = null
  } finally {
    hideLoading()
  }
}

const ligarAnuncio = async () => {
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar liga de anuncio?',
    html: `
      <div class="swal-selection-content">
        <p class="swal-confirmation-text">Se ligará el anuncio a la ${ligaType.value}:</p>
        <ul class="swal-list">
          <li><strong>Anuncio:</strong> ${anuncioEncontrado.value.anuncio}</li>
          <li><strong>${ligaType.value === 'licencia' ? 'Licencia' : 'Empresa'}:</strong>
            ${ligaType.value === 'licencia' ? targetEncontrado.value.licencia : targetEncontrado.value.empresa}
          </li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, ligar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  showLoading('Ligando anuncio...', 'Procesando solicitud')

  try {
    const response = await execute(
      'sp_ligar_anuncio',
      'padron_licencias',
      [
        { nombre: 'p_anuncio_id', valor: anuncioEncontrado.value.id_anuncio, tipo: 'integer' },
        { nombre: 'p_licencia_id', valor: ligaType.value === 'licencia' ? targetEncontrado.value.id_licencia : null, tipo: 'integer' },
        { nombre: 'p_empresa_id', valor: ligaType.value === 'empresa' ? targetEncontrado.value.id_licencia : null, tipo: 'integer' },
        { nombre: 'p_is_empresa', valor: ligaType.value === 'empresa', tipo: 'boolean' },
        { nombre: 'p_user', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.p_success) {
      await Swal.fire({
        icon: 'success',
        title: 'Anuncio Ligado',
        text: response.result[0].p_message || 'El anuncio ha sido ligado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Anuncio ligado exitosamente')
      resetForm()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al ligar',
        text: response?.result?.[0]?.p_message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const resetForm = () => {
  searchForm.value = {
    anuncioId: null,
    targetId: null
  }
  ligaType.value = ''
  anuncioEncontrado.value = null
  targetEncontrado.value = null
  hasSearched.value = false
}

// Lifecycle
onBeforeUnmount(() => {
  resetForm()
})
</script>

