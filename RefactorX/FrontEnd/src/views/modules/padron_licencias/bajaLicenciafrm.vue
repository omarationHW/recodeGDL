<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Licencia</h1>
        <p>Gestión de baja de licencias comerciales</p></div>
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
      <!-- Búsqueda de Licencia -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Licencia
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarLicencia">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Número de Licencia:</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="searchLicencia"
                    placeholder="Ingrese número de licencia"
                    required
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="loading || !searchLicencia"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información de la Licencia -->
      <div class="municipal-card" v-if="licenciaData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="file-contract" />
            Información de la Licencia #{{ licenciaData.licencia }}
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
                  <td class="label">Licencia:</td>
                  <td><strong>{{ licenciaData.licencia }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Propietario:</td>
                  <td>{{ licenciaData.propietario }}</td>
                </tr>
                <tr>
                  <td class="label">Actividad:</td>
                  <td>{{ licenciaData.actividad }}</td>
                </tr>
                <tr>
                  <td class="label">Ubicación:</td>
                  <td>{{ licenciaData.ubicacion }}</td>
                </tr>
                <tr>
                  <td class="label">Estado:</td>
                  <td>
                    <span :class="licenciaData.vigente === 'V' ? 'badge-success' : 'badge-danger'" class="badge">
                      {{ licenciaData.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                    </span>
                  </td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Anuncios ligados -->
          <div class="alert alert-info" v-if="anuncios.length > 0">
            <strong><font-awesome-icon icon="info-circle" /> Información:</strong>
            La licencia tiene {{ anuncios.length }} anuncio(s) ligado(s).
          </div>

          <!-- Formulario de Baja -->
          <div class="mt-4" v-if="licenciaData.vigente === 'V'">
            <h6 class="section-title">
              <font-awesome-icon icon="edit" />
              Registrar Baja
            </h6>
            <form @submit.prevent="confirmarBaja">
              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">Motivo de la baja *:</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="bajaForm.motivo"
                    rows="3"
                    placeholder="Ingrese el motivo de la baja"
                    required
                  ></textarea>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <div class="custom-control custom-checkbox">
                    <input
                      type="checkbox"
                      class="custom-control-input"
                      id="bajaError"
                      v-model="bajaForm.bajaError"
                    />
                    <label class="custom-control-label" for="bajaError">
                      Baja por error (no requiere año/folio)
                    </label>
                  </div>
                </div>
              </div>

              <div class="form-row" v-if="!bajaForm.bajaError">
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">Año *:</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="bajaForm.anio"
                    placeholder="2025"
                    min="2000"
                    max="2030"
                    :required="!bajaForm.bajaError"
                  />
                </div>
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">Folio *:</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="bajaForm.folio"
                    placeholder="1234"
                    min="1"
                    :required="!bajaForm.bajaError"
                  />
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
                    :disabled="loading"
                  >
                    <font-awesome-icon icon="ban" /> Dar de Baja Licencia
                  </button>
                  <button
                    type="button"
                    class="btn-municipal-secondary ms-2"
                    @click="cancelar"
                  >
                    <font-awesome-icon icon="times" /> Cancelar
                  </button>
                </div>
              </div>
            </form>
          </div>

          <div class="alert alert-warning" v-else>
            <strong>Esta licencia ya está dada de baja</strong>
            <p class="mb-0">Fecha de baja: {{ formatDate(licenciaData.fecha_baja) }}</p>
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
      :componentName="'bajaLicenciafrm'"
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
const searchLicencia = ref('')
const licenciaData = ref(null)
const anuncios = ref([])
const loading = ref(false)

const bajaForm = ref({
  motivo: '',
  anio: new Date().getFullYear(),
  folio: null,
  bajaError: false
})

// Métodos
const buscarLicencia = async () => {
  if (!searchLicencia.value) return

  loading.value = true
  try {
    // Buscar licencia usando el SP de baja
    const response = await execute(
      'sp_bajalicencia_buscar',
      'padron_licencias',
      [{ nombre: 'p_licencia', valor: parseInt(searchLicencia.value), tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      licenciaData.value = response.result[0]

      // Cargar anuncios ligados
      await cargarAnuncios()
    } else {
      Swal.fire({
        icon: 'error',
        title: 'No encontrada',
        text: 'La licencia no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      licenciaData.value = null
    }
  } catch (error) {
    console.error('Error al buscar licencia:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo buscar la licencia',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const cargarAnuncios = async () => {
  try {
    // Buscar anuncios ligados usando el SP específico
    const response = await execute(
      'sp_bajalicencia_anuncios',
      'padron_licencias',
      [{ nombre: 'p_id_licencia', valor: parseInt(licenciaData.value.id_licencia), tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result) {
      anuncios.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar anuncios:', error)
    anuncios.value = []
  }
}

const confirmarBaja = async () => {
  // Validaciones
  if (!bajaForm.value.motivo.trim()) {
    Swal.fire({
      icon: 'warning',
      title: 'Motivo requerido',
      text: 'Debe ingresar el motivo de la baja',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!bajaForm.value.bajaError && (!bajaForm.value.anio || !bajaForm.value.folio)) {
    Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Debe ingresar año y folio para baja normal',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Dar de baja licencia?',
    html: `
      <p>¿Está seguro de dar de baja la licencia <strong>#${licenciaData.value.licencia}</strong>?</p>
      <p><strong>Motivo:</strong> ${bajaForm.value.motivo}</p>
      <p class="text-danger"><strong>Esta acción NO se puede deshacer</strong></p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  loading.value = true
  try {
    // Ejecutar baja de licencia
    const response = await execute(
      'sp_bajalicencia_ejecutar',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: parseInt(searchLicencia.value), tipo: 'integer' },
        { nombre: 'p_motivo', valor: bajaForm.value.motivo, tipo: 'string' },
        { nombre: 'p_anio', valor: bajaForm.value.bajaError ? null : bajaForm.value.anio, tipo: 'integer' },
        { nombre: 'p_folio', valor: bajaForm.value.bajaError ? null : bajaForm.value.folio, tipo: 'integer' },
        { nombre: 'p_baja_error', valor: bajaForm.value.bajaError, tipo: 'boolean' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Baja registrada',
          text: resultado.message,
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        // Limpiar y recargar
        cancelar()
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
    console.error('Error al dar de baja:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo completar la baja de licencia',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const cancelar = () => {
  searchLicencia.value = ''
  licenciaData.value = null
  anuncios.value = []
  bajaForm.value = {
    motivo: '',
    anio: new Date().getFullYear(),
    folio: null,
    bajaError: false
  }
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX')
}
</script>
