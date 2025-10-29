<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Modificación de Trámites</h1>
        <p>Padrón de Licencias - Editar datos de trámites en proceso</p></div>
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
      <!-- Información del Trámite -->
      <div v-if="tramiteData" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-alt" />
            Trámite #{{ tramiteData.id_tramite }}
            <span class="badge" :class="getEstatusBadgeClass(tramiteData.estatus)">
              {{ getEstatusNombre(tramiteData.estatus) }}
            </span>
          </h5>
          <div class="button-group">
            <button
              v-if="!editMode"
              class="btn-municipal-primary"
              @click="habilitarEdicion"
              :disabled="loading || tramiteData.estatus === 'R' || tramiteData.estatus === 'C'"
            >
              <font-awesome-icon icon="edit" />
              Modificar
            </button>
            <button
              v-if="editMode"
              class="btn-municipal-success"
              @click="guardarCambios"
              :disabled="loading"
            >
              <font-awesome-icon icon="save" />
              Aceptar
            </button>
            <button
              v-if="editMode"
              class="btn-municipal-secondary"
              @click="cancelarEdicion"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Información General -->
          <div class="section-title">
            <font-awesome-icon icon="info-circle" />
            Información General
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Trámite</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tramiteData.id_tramite"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Trámite</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tramiteData.nombre_tipo_tramite"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Captura</label>
              <input
                type="date"
                class="municipal-form-control"
                :value="tramiteData.feccap"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Visita</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="tramiteData.fecha_visita"
                :readonly="!editMode"
              />
            </div>
          </div>

          <!-- Datos del Solicitante -->
          <div class="section-title">
            <font-awesome-icon icon="user" />
            Datos del Solicitante
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Propietario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="tramiteData.propietario"
                :readonly="!editMode"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="tramiteData.rfc"
                :readonly="!editMode"
                maxlength="13"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Teléfono</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="tramiteData.telefono_prop"
                :readonly="!editMode"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Email</label>
              <input
                type="email"
                class="municipal-form-control"
                v-model="tramiteData.email"
                :readonly="!editMode"
              />
            </div>
          </div>

          <!-- Domicilio del Propietario -->
          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Domicilio</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="tramiteData.domicilio"
                :readonly="!editMode"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Ext.</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="tramiteData.numext_prop"
                :readonly="!editMode"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Int.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="tramiteData.numint_prop"
                :readonly="!editMode"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="tramiteData.colonia_prop"
                :readonly="!editMode"
              />
            </div>
          </div>

          <!-- Giro y Actividad -->
          <div class="section-title">
            <font-awesome-icon icon="briefcase" />
            Giro y Actividad
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Giro SCIAN</label>
              <div class="input-group">
                <select
                  class="municipal-form-control"
                  v-model="selectedCodGiro"
                  @change="onGiroScianChange"
                  :disabled="!editMode || !puedeModificarGiro"
                >
                  <option value="">Seleccione giro...</option>
                  <option v-for="giro in girosScian" :key="giro.codigo_scian" :value="giro.codigo_scian">
                    {{ giro.codigo_scian }} - {{ giro.descripcion }}
                  </option>
                </select>
                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="buscarGiroScian"
                  :disabled="!editMode || !puedeModificarGiro"
                >
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Actividad Específica</label>
              <div class="input-group">
                <select
                  class="municipal-form-control"
                  v-model="tramiteData.id_giro"
                  @change="onActividadChange"
                  :disabled="!editMode || !puedeModificarGiro"
                >
                  <option value="">Seleccione actividad...</option>
                  <option v-for="act in actividades" :key="act.id_giro" :value="act.id_giro">
                    {{ act.descripcion }}
                  </option>
                </select>
                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="buscarActividad"
                  :disabled="!editMode || !puedeModificarGiro || !selectedCodGiro"
                >
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
          </div>

          <!-- Ubicación -->
          <div class="section-title">
            <font-awesome-icon icon="map-marker-alt" />
            Ubicación del Negocio
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Calle <span class="required">*</span></label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="tramiteData.ubicacion"
                  readonly
                />
                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="buscarCalle"
                  :disabled="!editMode"
                >
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Ext.</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="tramiteData.numext_ubic"
                :readonly="!editMode"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Int.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="tramiteData.numint_ubic"
                :readonly="!editMode"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="tramiteData.colonia_ubic"
                  readonly
                />
                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="buscarColonia"
                  :disabled="!editMode"
                >
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Código Postal</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="tramiteData.cp"
                readonly
              />
            </div>
          </div>

          <!-- Cruce de Calles -->
          <div class="section-title">
            <font-awesome-icon icon="map-signs" />
            Cruce de Calles
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Entre calles</label>
              <div class="cruce-display">
                <span v-if="cruceCalles.calle1 && cruceCalles.calle2">
                  Entre: <strong>{{ cruceCalles.calle1 }}</strong> y <strong>{{ cruceCalles.calle2 }}</strong>
                </span>
                <span v-else class="text-muted">Sin cruce definido</span>
              </div>
            </div>
            <div class="form-group">
              <button
                class="btn-municipal-primary"
                @click="modificarCruce"
                :disabled="!editMode"
              >
                <font-awesome-icon icon="map-signs" />
                Modificar Cruce
              </button>
            </div>
          </div>

          <!-- Geolocalización -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación GPS
              </label>
              <button
                class="btn-municipal-primary"
                @click="abrirMapa"
                :disabled="!editMode"
              >
                <font-awesome-icon icon="map" />
                Abrir Mapa para Geolocalización
              </button>
            </div>
            <div class="form-group" v-if="coordenadasSeleccionadas">
              <label class="municipal-form-label">Coordenadas</label>
              <div class="badge-success" style="padding: 8px;">
                <font-awesome-icon icon="check-circle" />
                Lat: {{ coordenadasSeleccionadas.lat }} / Lng: {{ coordenadasSeleccionadas.lng }}
              </div>
            </div>
          </div>

          <!-- Observaciones -->
          <div class="section-title">
            <font-awesome-icon icon="comment" />
            Observaciones
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 3;">
              <label class="municipal-form-label">Observaciones</label>
              <div class="input-group">
                <textarea
                  class="municipal-form-control"
                  v-model="tramiteData.observaciones"
                  rows="3"
                  :readonly="!editMode"
                ></textarea>
                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="agregarObservacion"
                  :disabled="!editMode"
                >
                  <font-awesome-icon icon="plus" />
                </button>
              </div>
            </div>
          </div>

          <!-- Pago de Solicitud -->
          <div class="form-row">
            <div class="form-group">
              <label class="checkbox-label">
                <input
                  type="checkbox"
                  v-model="pagaSolicitud"
                  :disabled="!editMode"
                />
                Paga solicitud
              </label>
            </div>
          </div>

          <!-- Botón de Inspecciones -->
          <div v-if="editMode" class="button-group" style="margin-top: 20px;">
            <button
              class="btn-municipal-warning"
              @click="abrirPanelInspecciones"
              :disabled="loading"
            >
              <font-awesome-icon icon="clipboard-check" />
              Administrar Inspecciones
            </button>
          </div>
        </div>
      </div>

      <!-- Panel de Revisiones/Inspecciones -->
      <div v-if="showPanelInspecciones" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="clipboard-check" />
            Revisiones por Dependencia
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Dependencia</th>
                  <th>Fecha Inicio</th>
                  <th>Fecha Término</th>
                  <th>Estatus</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="rev in revisiones" :key="rev.id_revision" class="row-hover">
                  <td>{{ rev.id_revision }}</td>
                  <td>{{ rev.nombre_dependencia }}</td>
                  <td>{{ formatDate(rev.fecha_inicio) }}</td>
                  <td>{{ formatDate(rev.fecha_termino) }}</td>
                  <td>
                    <span class="badge" :class="getEstatusBadgeClass(rev.estatus)">
                      {{ rev.nombre_estatus }}
                    </span>
                  </td>
                  <td>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="eliminarRevision(rev.id_revision)"
                      :disabled="loading"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </td>
                </tr>
                <tr v-if="revisiones.length === 0">
                  <td colspan="6" class="text-center text-muted">
                    No hay revisiones registradas
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="button-group" style="margin-top: 20px;">
            <button
              v-if="!modoAgregarRevision"
              class="btn-municipal-primary"
              @click="iniciarAgregarRevision"
              :disabled="loading"
            >
              <font-awesome-icon icon="plus" />
              Agregar Revisión
            </button>

            <div v-if="modoAgregarRevision" class="form-row">
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Dependencia</label>
                <select class="municipal-form-control" v-model="nuevaRevision.id_dependencia">
                  <option value="">Seleccione dependencia...</option>
                  <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">
                    {{ dep.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <button
                  class="btn-municipal-success"
                  @click="guardarRevision"
                  :disabled="loading || !nuevaRevision.id_dependencia"
                  style="margin-top: 24px;"
                >
                  <font-awesome-icon icon="check" />
                  Aceptar
                </button>
                <button
                  class="btn-municipal-secondary"
                  @click="cancelarAgregarRevision"
                  :disabled="loading"
                  style="margin-top: 24px; margin-left: 10px;"
                >
                  <font-awesome-icon icon="times" />
                  Cancelar
                </button>
              </div>
            </div>

            <button
              class="btn-municipal-secondary"
              @click="cerrarPanelInspecciones"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Cerrar
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje si no hay trámite cargado -->
      <div v-if="!tramiteData" class="municipal-card">
        <div class="municipal-card-body text-center">
          <font-awesome-icon icon="file-alt" size="3x" class="text-muted" />
          <p class="text-muted" style="margin-top: 20px;">
            No hay trámite cargado. Este componente debe ser llamado con un ID de trámite.
          </p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'modtramitefrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const route = useRoute()
const { execute } = useApi()
const {
  loading,
  loadingMessage,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const tramiteData = ref(null)
const editMode = ref(false)
const tramiteOriginal = ref(null)
const girosScian = ref([])
const actividades = ref([])
const selectedCodGiro = ref('')
const cruceCalles = ref({ calle1: '', calle2: '', cvecalle1: null, cvecalle2: null })
const coordenadasSeleccionadas = ref(null)
const sesionMapa = ref(null)
const pagaSolicitud = ref(true)
const showPanelInspecciones = ref(false)
const revisiones = ref([])
const dependencias = ref([])
const modoAgregarRevision = ref(false)
const nuevaRevision = ref({ id_dependencia: null })

// Computed
const puedeModificarGiro = computed(() => {
  if (!tramiteData.value) return false
  const estatus = tramiteData.value.estatus
  return estatus === 'T' || estatus === 'A'
})

// Métodos de carga
const loadTramite = async (idTramite) => {
  setLoading(true, 'Cargando trámite...')

  try {
    const response = await execute(
      'SP_MODTRAMITE_BUSCAR',
      'padron_licencias',
      [{ nombre: 'p_id_tramite', valor: idTramite, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tramiteData.value = response.result[0]
      tramiteOriginal.value = JSON.parse(JSON.stringify(tramiteData.value))

      // Cargar giros si hay un giro
      if (tramiteData.value.cod_giro) {
        selectedCodGiro.value = tramiteData.value.cod_giro
        await loadGirosScian()
        await loadActividades(tramiteData.value.cod_giro)
      }

      // Cargar cruce de calles
      if (tramiteData.value.cvecalle1) {
        await loadCruceCalles(tramiteData.value.cvecalle1, tramiteData.value.cvecalle2)
      }

      showToast('success', 'Trámite cargado correctamente')
    } else {
      showToast('error', 'Trámite no encontrado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const loadGirosScian = async () => {
  try {
    const response = await execute(
      'SP_GET_SCIAN_CATALOGO',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      girosScian.value = response.result
    }
  } catch (error) {
    console.error('Error cargando giros SCIAN:', error)
  }
}

const loadActividades = async (codGiro) => {
  try {
    const response = await execute(
      'SP_GET_ACTIVIDADES_POR_SCIAN',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: 'L', tipo: 'string' },
        { nombre: 'p_cod_giro', valor: parseInt(codGiro), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      actividades.value = response.result
    }
  } catch (error) {
    console.error('Error cargando actividades:', error)
  }
}

const loadCruceCalles = async (cvecalle1, cvecalle2) => {
  try {
    const response1 = await execute(
      'SP_GET_CALLE_POR_ID',
      'padron_licencias',
      [{ nombre: 'p_cvecalle', valor: cvecalle1, tipo: 'integer' }],
      'guadalajara'
    )

    const response2 = await execute(
      'SP_GET_CALLE_POR_ID',
      'padron_licencias',
      [{ nombre: 'p_cvecalle', valor: cvecalle2, tipo: 'integer' }],
      'guadalajara'
    )

    if (response1 && response1.result && response1.result.length > 0) {
      cruceCalles.value.calle1 = response1.result[0].calle
      cruceCalles.value.cvecalle1 = cvecalle1
    }

    if (response2 && response2.result && response2.result.length > 0) {
      cruceCalles.value.calle2 = response2.result[0].calle
      cruceCalles.value.cvecalle2 = cvecalle2
    }
  } catch (error) {
    console.error('Error cargando cruce de calles:', error)
  }
}

const loadRevisiones = async (idTramite) => {
  try {
    const response = await execute(
      'SP_MODTRAMITE_OBTENER_REVISIONES',
      'padron_licencias',
      [{ nombre: 'p_id_tramite', valor: idTramite, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result) {
      revisiones.value = response.result
    }
  } catch (error) {
    console.error('Error cargando revisiones:', error)
  }
}

const loadDependencias = async () => {
  try {
    const response = await execute(
      'SP_GET_DEPENDENCIAS',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      dependencias.value = response.result
    }
  } catch (error) {
    console.error('Error cargando dependencias:', error)
  }
}

// Métodos de edición
const habilitarEdicion = () => {
  if (tramiteData.value.estatus === 'R') {
    showToast('error', 'El trámite ya fue rechazado, no puede modificarse')
    return
  }

  if (tramiteData.value.estatus === 'C') {
    showToast('error', 'El trámite está cancelado, no puede modificarse')
    return
  }

  editMode.value = true
  showToast('info', 'Modo de edición habilitado')
}

const cancelarEdicion = () => {
  tramiteData.value = JSON.parse(JSON.stringify(tramiteOriginal.value))
  editMode.value = false
  showPanelInspecciones.value = false
  showToast('info', 'Cambios cancelados')
}

const guardarCambios = async () => {
  // Validaciones
  if (!tramiteData.value.cvecalle || tramiteData.value.cvecalle === 0) {
    showToast('warning', 'Debe indicar un nombre de calle')
    return
  }

  // Solicitar firma
  const firmaResult = await solicitarFirma()
  if (!firmaResult.success) return

  setLoading(true, 'Guardando cambios...')

  try {
    // Actualizar trámite
    const response = await execute(
      'SP_MODTRAMITE_ACTUALIZAR',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: tramiteData.value.id_tramite, tipo: 'integer' },
        { nombre: 'p_propietario', valor: tramiteData.value.propietario, tipo: 'string' },
        { nombre: 'p_rfc', valor: tramiteData.value.rfc, tipo: 'string' },
        { nombre: 'p_domicilio', valor: tramiteData.value.domicilio, tipo: 'string' },
        { nombre: 'p_numext_prop', valor: tramiteData.value.numext_prop, tipo: 'integer' },
        { nombre: 'p_numint_prop', valor: tramiteData.value.numint_prop, tipo: 'string' },
        { nombre: 'p_colonia_prop', valor: tramiteData.value.colonia_prop, tipo: 'string' },
        { nombre: 'p_telefono_prop', valor: tramiteData.value.telefono_prop, tipo: 'string' },
        { nombre: 'p_email', valor: tramiteData.value.email, tipo: 'string' },
        { nombre: 'p_ubicacion', valor: tramiteData.value.ubicacion, tipo: 'string' },
        { nombre: 'p_cvecalle', valor: tramiteData.value.cvecalle, tipo: 'integer' },
        { nombre: 'p_numext_ubic', valor: tramiteData.value.numext_ubic, tipo: 'integer' },
        { nombre: 'p_numint_ubic', valor: tramiteData.value.numint_ubic, tipo: 'string' },
        { nombre: 'p_colonia_ubic', valor: tramiteData.value.colonia_ubic, tipo: 'string' },
        { nombre: 'p_cp', valor: tramiteData.value.cp, tipo: 'integer' },
        { nombre: 'p_id_giro', valor: tramiteData.value.id_giro, tipo: 'integer' },
        { nombre: 'p_actividad', valor: tramiteData.value.actividad, tipo: 'string' },
        { nombre: 'p_observaciones', valor: tramiteData.value.observaciones, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      // Actualizar cruce de calles
      await actualizarCruceCalles()

      // Si hay coordenadas, actualizarlas
      if (coordenadasSeleccionadas.value && sesionMapa.value) {
        await actualizarCoordenadas()
      }

      await Swal.fire({
        icon: 'success',
        title: 'Trámite Actualizado',
        text: 'El trámite se actualizó correctamente',
        confirmButtonColor: '#ea8215'
      })

      // Recargar datos
      await loadTramite(tramiteData.value.id_tramite)
      editMode.value = false
    } else {
      showToast('error', 'Error al actualizar el trámite')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Eventos de cambio
const onGiroScianChange = async () => {
  if (selectedCodGiro.value) {
    await loadActividades(selectedCodGiro.value)
    tramiteData.value.id_giro = null
  }
}

const onActividadChange = () => {
  const actividadSeleccionada = actividades.value.find(a => a.id_giro === tramiteData.value.id_giro)
  if (actividadSeleccionada) {
    tramiteData.value.actividad = actividadSeleccionada.descripcion
  }
}

// Métodos de inspecciones
const abrirPanelInspecciones = async () => {
  // Solicitar firma
  const firmaResult = await solicitarFirma()
  if (!firmaResult.success) return

  await loadRevisiones(tramiteData.value.id_tramite)
  await loadDependencias()
  showPanelInspecciones.value = true
}

const cerrarPanelInspecciones = () => {
  showPanelInspecciones.value = false
  modoAgregarRevision.value = false
}

const iniciarAgregarRevision = () => {
  modoAgregarRevision.value = true
  nuevaRevision.value = { id_dependencia: null }
}

const cancelarAgregarRevision = () => {
  modoAgregarRevision.value = false
  nuevaRevision.value = { id_dependencia: null }
}

const guardarRevision = async () => {
  setLoading(true, 'Agregando revisión...')

  try {
    // Aquí iría el SP para agregar revisión
    // Por ahora usaremos un placeholder

    await Swal.fire({
      icon: 'success',
      title: 'Revisión Agregada',
      text: 'La revisión se agregó correctamente',
      confirmButtonColor: '#ea8215'
    })

    await loadRevisiones(tramiteData.value.id_tramite)
    modoAgregarRevision.value = false
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const eliminarRevision = async (idRevision) => {
  const result = await Swal.fire({
    title: '¿Eliminar revisión?',
    text: 'Esta acción no se puede deshacer',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  setLoading(true, 'Eliminando revisión...')

  try {
    // Aquí iría el SP para eliminar revisión
    await loadRevisiones(tramiteData.value.id_tramite)
    showToast('success', 'Revisión eliminada')
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Métodos auxiliares
const actualizarCruceCalles = async () => {
  if (!cruceCalles.value.cvecalle1 || !cruceCalles.value.cvecalle2) return

  try {
    await execute(
      'SP_ACTUALIZAR_CRUCE_CALLES',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: tramiteData.value.id_tramite, tipo: 'integer' },
        { nombre: 'p_cvecalle1', valor: cruceCalles.value.cvecalle1, tipo: 'integer' },
        { nombre: 'p_cvecalle2', valor: cruceCalles.value.cvecalle2, tipo: 'integer' }
      ],
      'guadalajara'
    )
  } catch (error) {
    console.error('Error actualizando cruce:', error)
  }
}

const abrirMapa = async () => {
  // Solicitar firma especial para geolocalización
  const firmaResult = await solicitarFirmaUsuario()
  if (!firmaResult.success) return

  try {
    const response = await execute(
      'SP_GET_SESSION_ID',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.sessionid) {
      sesionMapa.value = response.result[0].sessionid

      await execute(
        'SP_MODLIC_LIMPIAR_SESION',
        'padron_licencias',
        [{ nombre: 'p_sesion_id', valor: sesionMapa.value, tipo: 'integer' }],
        'guadalajara'
      )

      const urlMapa = `https://modulos.guadalajara.gob.mx/ubicacion/index.php?sesid=${sesionMapa.value}`
      window.open(urlMapa, '_blank')

      showToast('info', 'Mapa abierto. Seleccione la ubicación y regrese aquí.')
      iniciarPollingUbicacion()
    }
  } catch (error) {
    handleApiError(error)
  }
}

const iniciarPollingUbicacion = () => {
  const intervalo = setInterval(async () => {
    try {
      const response = await execute(
        'SP_GET_UBICACION_SESION',
        'padron_licencias',
        [{ nombre: 'p_sesion_id', valor: sesionMapa.value, tipo: 'integer' }],
        'guadalajara'
      )

      if (response && response.result && response.result.length > 0) {
        const ubicacion = response.result[0]
        coordenadasSeleccionadas.value = {
          lat: ubicacion.lti,
          lng: ubicacion.lgi
        }

        showToast('success', 'Ubicación registrada')
        clearInterval(intervalo)
      }
    } catch (error) {
      console.error('Error verificando ubicación:', error)
    }
  }, 3000)

  setTimeout(() => clearInterval(intervalo), 300000)
}

const actualizarCoordenadas = async () => {
  try {
    await execute(
      'SP_MODTRAMITE_ACTUALIZAR_UBICACION',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: tramiteData.value.id_tramite, tipo: 'integer' },
        { nombre: 'p_sesion_id', valor: sesionMapa.value, tipo: 'integer' }
      ],
      'guadalajara'
    )
  } catch (error) {
    console.error('Error actualizando coordenadas:', error)
  }
}

const solicitarFirma = async () => {
  const { value: firma } = await Swal.fire({
    title: 'Firma de Autorización',
    input: 'password',
    inputLabel: 'Ingrese su firma:',
    inputPlaceholder: 'Firma',
    showCancelButton: true,
    confirmButtonText: 'Aceptar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    inputValidator: (value) => {
      if (!value) return 'Debe ingresar su firma'
    }
  })

  if (!firma) return { success: false }

  try {
    const response = await execute(
      'SP_VERIFICA_FIRMA',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: localStorage.getItem('usuario') || '', tipo: 'string' },
        { nombre: 'p_login', valor: '', tipo: 'string' },
        { nombre: 'p_firma', valor: firma, tipo: 'string' },
        { nombre: 'p_modulos_id', valor: 1, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const resultado = response.result[0]
      if (resultado.acceso > 0) {
        await Swal.fire({
          icon: 'error',
          title: 'Acceso Denegado',
          text: resultado.mensaje,
          confirmButtonColor: '#ea8215'
        })
        return { success: false }
      }
    }

    return { success: true }
  } catch (error) {
    handleApiError(error)
    return { success: false }
  }
}

const solicitarFirmaUsuario = async () => {
  const { value: formValues } = await Swal.fire({
    title: 'Firma de Autorización - Ubicación',
    html:
      '<input id="swal-input1" class="swal2-input" placeholder="Usuario">' +
      '<input id="swal-input2" type="password" class="swal2-input" placeholder="Firma">',
    focusConfirm: false,
    showCancelButton: true,
    confirmButtonText: 'Aceptar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    preConfirm: () => {
      return {
        usuario: document.getElementById('swal-input1').value,
        firma: document.getElementById('swal-input2').value
      }
    }
  })

  if (!formValues || !formValues.usuario || !formValues.firma) {
    return { success: false }
  }

  try {
    const response = await execute(
      'SP_VERIFICA_FIRMA',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: formValues.usuario, tipo: 'string' },
        { nombre: 'p_login', valor: '', tipo: 'string' },
        { nombre: 'p_firma', valor: formValues.firma, tipo: 'string' },
        { nombre: 'p_modulos_id', valor: 2, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const resultado = response.result[0]
      if (resultado.acceso > 0) {
        await Swal.fire({
          icon: 'error',
          title: 'Acceso Denegado',
          text: resultado.mensaje,
          confirmButtonColor: '#ea8215'
        })
        return { success: false }
      }
    }

    return { success: true }
  } catch (error) {
    handleApiError(error)
    return { success: false }
  }
}

// Búsquedas (placeholders)
const buscarGiroScian = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Giro SCIAN',
    text: 'Funcionalidad en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const buscarActividad = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Actividad',
    text: 'Funcionalidad en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const buscarCalle = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Calle',
    text: 'Funcionalidad en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const buscarColonia = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Colonia',
    text: 'Funcionalidad en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const modificarCruce = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Modificar Cruce de Calles',
    text: 'Funcionalidad en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const agregarObservacion = async () => {
  const { value: observacion } = await Swal.fire({
    title: 'Agregar Observación',
    input: 'textarea',
    inputLabel: 'Observaciones',
    inputPlaceholder: 'Escriba sus observaciones aquí...',
    showCancelButton: true,
    confirmButtonText: 'Agregar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215'
  })

  if (observacion) {
    tramiteData.value.observaciones = tramiteData.value.observaciones
      ? `${tramiteData.value.observaciones}\n${observacion}`
      : observacion
  }
}

// Utilidades
const getEstatusBadgeClass = (estatus) => {
  const classes = {
    'T': 'badge-warning',  // En trámite
    'A': 'badge-success',  // Aprobado
    'R': 'badge-danger',   // Rechazado
    'C': 'badge-secondary', // Cancelado
    'P': 'badge-info',     // Pendiente
    'V': 'badge-primary'   // Vigente
  }
  return classes[estatus] || 'badge-secondary'
}

const getEstatusNombre = (estatus) => {
  const nombres = {
    'T': 'En Trámite',
    'A': 'Aprobado',
    'R': 'Rechazado',
    'C': 'Cancelado',
    'P': 'Pendiente',
    'V': 'Vigente'
  }
  return nombres[estatus] || 'Desconocido'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Lifecycle
onMounted(async () => {
  // Obtener ID del trámite desde route params o props
  const idTramite = route.params.id || route.query.id

  if (idTramite) {
    await loadTramite(parseInt(idTramite))
  }

  await loadGirosScian()
})
</script>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #2c5282;
  margin: 25px 0 15px 0;
  padding-bottom: 8px;
  border-bottom: 2px solid #e2e8f0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.cruce-display {
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border: 1px solid #dee2e6;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}

.checkbox-label input[type="checkbox"] {
  cursor: pointer;
  width: 18px;
  height: 18px;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
  }

  .form-group {
    width: 100% !important;
  }
}
</style>
