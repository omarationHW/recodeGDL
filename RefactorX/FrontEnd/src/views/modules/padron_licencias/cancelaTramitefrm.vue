<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="times-circle" />
      </div>
      <div class="module-view-info">
        <h1>Cancelación de Trámites</h1>
        <p>Gestión de cancelación de trámites en proceso</p></div>
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
      <!-- Búsqueda de Trámite -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Trámite
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarTramite">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Número de Trámite:</label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="searchIdTramite"
                    placeholder="Ingrese número de trámite"
                    required
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="loading || !searchIdTramite"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del Trámite -->
      <div class="municipal-card" v-if="tramiteData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="file-alt" />
            Información del Trámite #{{ tramiteData.id_tramite }}
            <span
              class="badge ms-2"
              :class="{
                'badge-success': tramiteData.estatus === 'A',
                'badge-danger': tramiteData.estatus === 'C',
                'badge-warning': tramiteData.estatus === 'T',
                'badge-secondary': tramiteData.estatus === 'R'
              }"
            >
              {{ getEstatusText(tramiteData.estatus) }}
            </span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="details-grid">
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="id-card" />
                Datos Generales
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">ID Trámite:</td>
                  <td><strong>{{ tramiteData.id_tramite }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Folio:</td>
                  <td>{{ tramiteData.folio || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Tipo:</td>
                  <td>{{ tramiteData.tipo_tramite }}</td>
                </tr>
                <tr>
                  <td class="label">Recaudadora:</td>
                  <td>{{ tramiteData.recaud }}</td>
                </tr>
                <tr>
                  <td class="label">Propietario:</td>
                  <td>{{ tramiteData.propietario_completo }}</td>
                </tr>
                <tr>
                  <td class="label">Giro:</td>
                  <td>{{ tramiteData.giro_descripcion || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Actividad:</td>
                  <td>{{ tramiteData.actividad }}</td>
                </tr>
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Domicilio:</td>
                  <td>{{ tramiteData.ubicacion }}</td>
                </tr>
                <tr>
                  <td class="label">No. Ext:</td>
                  <td>{{ tramiteData.numext_ubic || 'S/N' }} {{ tramiteData.letraext_ubic }}</td>
                </tr>
                <tr>
                  <td class="label">No. Int:</td>
                  <td>{{ tramiteData.numint_ubic || 'N/A' }} {{ tramiteData.letraint_ubic }}</td>
                </tr>
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="ruler-combined" />
                Datos Técnicos
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Sup. Construida:</td>
                  <td>{{ tramiteData.sup_construida }} m²</td>
                </tr>
                <tr>
                  <td class="label">Sup. Autorizada:</td>
                  <td>{{ tramiteData.sup_autorizada }} m²</td>
                </tr>
                <tr>
                  <td class="label">Num. Cajones:</td>
                  <td>{{ tramiteData.num_cajones }}</td>
                </tr>
                <tr>
                  <td class="label">Num. Empleados:</td>
                  <td>{{ tramiteData.num_empleados }}</td>
                </tr>
              </table>
            </div>

            <div class="detail-section" v-if="tramiteData.licencia_ref || tramiteData.id_licencia">
              <h6 class="section-title">
                <font-awesome-icon icon="link" />
                Referencias
              </h6>
              <table class="detail-table">
                <tr v-if="tramiteData.licencia_ref">
                  <td class="label">Licencia Ref:</td>
                  <td>{{ tramiteData.licencia_ref }}</td>
                </tr>
                <tr v-if="tramiteData.id_licencia">
                  <td class="label">ID Licencia:</td>
                  <td>{{ tramiteData.id_licencia }}</td>
                </tr>
                <tr v-if="tramiteData.id_anuncio">
                  <td class="label">ID Anuncio:</td>
                  <td>{{ tramiteData.id_anuncio }}</td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="mt-4">
            <button
              class="btn-municipal-danger"
              :disabled="!puedeCancelar"
              @click="confirmarCancelacion"
            >
              <font-awesome-icon icon="times-circle" /> Cancelar Trámite
            </button>
            <button
              class="btn-municipal-secondary ms-2"
              @click="limpiar"
            >
              <font-awesome-icon icon="times" /> Limpiar
            </button>
          </div>

          <!-- Alertas -->
          <div class="alert alert-danger mt-3" v-if="tramiteData.estatus === 'C'">
            <strong><font-awesome-icon icon="exclamation-triangle" /> Trámite Cancelado</strong>
            <p class="mb-0">Este trámite ya se encuentra cancelado.</p>
          </div>

          <div class="alert alert-warning mt-3" v-if="tramiteData.estatus === 'A'">
            <strong><font-awesome-icon icon="exclamation-triangle" /> Trámite Autorizado</strong>
            <p class="mb-0">Este trámite ya fue autorizado. Para dar de baja use el módulo de Baja de Licencias.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando...</p>
      </div>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'cancelaTramitefrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import Swal from 'sweetalert2'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()

// Estado
const searchIdTramite = ref('')
const tramiteData = ref(null)
const loading = ref(false)

// Computed
const puedeCancelar = computed(() => {
  if (!tramiteData.value) return false
  const estatus = tramiteData.value.estatus
  // Solo puede cancelar si está en trámite (T) o rechazado (R)
  return estatus === 'T' || estatus === 'R'
})

// Métodos
const buscarTramite = async () => {
  if (!searchIdTramite.value) return

  loading.value = true
  try {
    const response = await execute(
      'sp_cancelatramite_buscar',
      'padron_licencias',
      [{ nombre: 'p_id_tramite', valor: parseInt(searchIdTramite.value), tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tramiteData.value = response.result[0]
    } else {
      Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El trámite no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      tramiteData.value = null
    }
  } catch (error) {
    console.error('Error al buscar trámite:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo buscar el trámite',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const confirmarCancelacion = async () => {
  // Solicitar motivo de cancelación
  const { value: motivo } = await Swal.fire({
    title: 'Motivo de Cancelación',
    html: `
      <p>Ingrese el motivo por el cual se cancela el trámite <strong>#${tramiteData.value.id_tramite}</strong>:</p>
      <textarea id="swal-motivo" class="swal2-textarea" placeholder="Motivo de la cancelación..." rows="4"></textarea>
    `,
    focusConfirm: false,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Cancelar Trámite',
    cancelButtonText: 'Volver',
    preConfirm: () => {
      const motivo = document.getElementById('swal-motivo').value
      if (!motivo || !motivo.trim()) {
        Swal.showValidationMessage('Debe ingresar el motivo de la cancelación')
      }
      return motivo
    }
  })

  if (!motivo) return

  // Confirmación final
  const confirmacion = await Swal.fire({
    icon: 'warning',
    title: '¿Cancelar trámite?',
    html: `
      <p>¿Está seguro de cancelar el trámite <strong>#${tramiteData.value.id_tramite}</strong>?</p>
      <p><strong>Motivo:</strong> ${motivo}</p>
      <p class="text-danger"><strong>Esta acción NO se puede deshacer</strong></p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No, volver'
  })

  if (!confirmacion.isConfirmed) return

  loading.value = true
  try {
    const response = await execute(
      'sp_cancelatramite_ejecutar',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(searchIdTramite.value), tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Cancelación exitosa',
          text: resultado.message,
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        // Actualizar el estado local
        tramiteData.value.estatus = 'C'
      } else {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    console.error('Error al cancelar trámite:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo completar la cancelación del trámite',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const limpiar = () => {
  searchIdTramite.value = ''
  tramiteData.value = null
}

const getEstatusText = (estatus) => {
  const estados = {
    'A': 'Autorizado',
    'C': 'Cancelado',
    'T': 'En Trámite',
    'R': 'Rechazado'
  }
  return estados[estatus] || estatus
}
</script>
