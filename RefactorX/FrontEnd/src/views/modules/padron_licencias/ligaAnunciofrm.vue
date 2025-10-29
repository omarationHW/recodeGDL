<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="link" />
      </div>
      <div class="module-view-info">
        <h1>Liga de Anuncios</h1>
        <p>Padrón de Licencias - Ligar/Desligar Anuncios a Licencias o Empresas</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
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
              :disabled="loading || !searchForm.anuncioId"
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
              :disabled="loading || !searchForm.targetId"
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
            :disabled="loading"
          >
            <font-awesome-icon icon="link" />
            Ligar Anuncio
          </button>
          <button
            class="btn-municipal-secondary"
            @click="resetForm"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando...</p>
      </div>
    </div>

    <!-- Toast Notification -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ligaAnunciofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const searchForm = ref({
  anuncioId: null,
  targetId: null
})

const ligaType = ref('') // 'licencia' o 'empresa'
const anuncioEncontrado = ref(null)
const targetEncontrado = ref(null)

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

  setLoading(true, 'Buscando anuncio...')

  try {
    const response = await execute(
      'SP_BUSCAR_ANUNCIO',
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
    setLoading(false)
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

  setLoading(true, `Buscando ${ligaType.value}...`)

  try {
    const spName = ligaType.value === 'licencia' ? 'SP_BUSCAR_LICENCIA' : 'SP_BUSCAR_EMPRESA'
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
    setLoading(false)
  }
}

const ligarAnuncio = async () => {
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar liga de anuncio?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se ligará el anuncio a la ${ligaType.value}:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Anuncio:</strong> ${anuncioEncontrado.value.anuncio}</li>
          <li style="margin: 5px 0;"><strong>${ligaType.value === 'licencia' ? 'Licencia' : 'Empresa'}:</strong>
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

  setLoading(true, 'Ligando anuncio...')

  try {
    const response = await execute(
      'SP_LIGAR_ANUNCIO',
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
    setLoading(false)
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
}

// Lifecycle
onBeforeUnmount(() => {
  resetForm()
})
</script>

<style scoped>
.align-end {
  display: flex;
  align-items: flex-end;
}

.info-box {
  margin-top: 1.5rem;
  padding: 1.5rem;
  border-radius: 8px;
  border: 2px solid;
}

.info-success {
  background-color: #d4edda;
  border-color: #28a745;
}

.info-primary {
  background-color: #cfe2ff;
  border-color: #0d6efd;
}

.info-box h6 {
  margin: 0 0 1rem 0;
  font-size: 1.1rem;
  font-weight: bold;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item strong {
  font-size: 0.9rem;
  color: #666;
}

.info-item span {
  font-size: 1rem;
}

.radio-group {
  display: flex;
  gap: 2rem;
  margin-top: 0.5rem;
}

.radio-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-size: 1.1rem;
}

.radio-option input[type="radio"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.confirmation-box {
  display: flex;
  align-items: center;
  gap: 2rem;
  padding: 2rem;
  background-color: #fff3cd;
  border: 2px solid #ffc107;
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

.confirmation-icon {
  flex-shrink: 0;
  color: #ffc107;
}

.confirmation-content h4 {
  margin: 0 0 0.5rem 0;
  font-size: 1.3rem;
}

.confirmation-content p {
  margin: 0 0 1rem 0;
}

.confirmation-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.confirmation-list li {
  margin: 0.5rem 0;
  font-size: 1rem;
}
</style>
