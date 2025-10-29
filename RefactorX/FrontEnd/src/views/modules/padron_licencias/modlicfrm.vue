<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Modificación de Licencias y Anuncios</h1>
        <p>Padrón de Licencias - Editar datos de licencias y anuncios existentes</p>
      </div>
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
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="width: 250px;">
              <label class="municipal-form-label">Buscar <span class="required">*</span></label>
              <div class="radio-group">
                <label class="radio-label">
                  <input type="radio" v-model="searchType" value="licencia" />
                  Licencia
                </label>
                <label class="radio-label">
                  <input type="radio" v-model="searchType" value="anuncio" />
                  Anuncio
                </label>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Número <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="searchNumber"
                @keyup.enter="buscar"
                placeholder="Ingrese número..."
              />
            </div>
            <div class="form-group" style="align-self: flex-end;">
              <button
                class="btn-municipal-primary"
                @click="buscar"
                :disabled="loading || !searchNumber"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Panel de Licencia -->
      <div v-if="licenciaData && searchType === 'licencia'" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="id-card" />
            Datos de la Licencia #{{ licenciaData.licencia }}
            <span v-if="licenciaData.vigente !== 'V'" class="badge-danger">BAJA</span>
            <span v-else class="badge-success">VIGENTE</span>
          </h5>
          <div class="button-group">
            <button
              v-if="licenciaData.vigente !== 'V'"
              class="btn-municipal-success btn-sm"
              @click="reactivarLicencia"
            >
              <font-awesome-icon icon="check-circle" />
              Reactivar
            </button>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Información del Propietario -->
          <div class="section-title">
            <font-awesome-icon icon="user" />
            Información del Propietario
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Propietario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.propietario"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Primer Apellido</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.primer_ap"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Segundo Apellido</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.segundo_ap"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.rfc"
                maxlength="13"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">CURP</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.curp"
                maxlength="18"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Email</label>
              <input
                type="email"
                class="municipal-form-control"
                v-model="licenciaData.email"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Teléfono</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.telefono_prop"
              />
            </div>
          </div>

          <!-- Domicilio del Propietario -->
          <div class="section-title">
            <font-awesome-icon icon="home" />
            Domicilio del Propietario
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Domicilio</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.domicilio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Ext.</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.numext_prop"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Int.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.numint_prop"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.colonia_prop"
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
              <label class="municipal-form-label">Giro SCIAN <span class="required">*</span></label>
              <div class="input-group">
                <select class="municipal-form-control" v-model="selectedCodGiro" @change="onGiroScianChange">
                  <option value="">Seleccione giro...</option>
                  <option v-for="giro in girosScian" :key="giro.codigo_scian" :value="giro.codigo_scian">
                    {{ giro.codigo_scian }} - {{ giro.descripcion }}
                  </option>
                </select>
                <button class="btn-municipal-secondary btn-sm" @click="buscarGiroScian">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Actividad Específica <span class="required">*</span></label>
              <div class="input-group">
                <select class="municipal-form-control" v-model="licenciaData.id_giro" @change="onActividadChange">
                  <option value="">Seleccione actividad...</option>
                  <option v-for="act in actividades" :key="act.id_giro" :value="act.id_giro">
                    {{ act.descripcion }}
                  </option>
                </select>
                <button class="btn-municipal-secondary btn-sm" @click="buscarActividad" :disabled="!selectedCodGiro">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
          </div>

          <!-- Ubicación del Negocio -->
          <div class="section-title">
            <font-awesome-icon icon="map-marker-alt" />
            Ubicación del Negocio
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Calle</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="licenciaData.ubicacion"
                  readonly
                />
                <button class="btn-municipal-secondary btn-sm" @click="buscarCalle">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Ext.</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.numext_ubic"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra Ext.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.letraext_ubic"
                maxlength="5"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Int.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.numint_ubic"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra Int.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.letraint_ubic"
                maxlength="5"
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
                  v-model="licenciaData.colonia_ubic"
                />
                <button class="btn-municipal-secondary btn-sm" @click="buscarColonia">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Código Postal</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.cp"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.zona"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Subzona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.subzona"
                readonly
              />
            </div>
          </div>

          <!-- Coordenadas GPS -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación GPS
              </label>
              <button
                class="btn-municipal-primary"
                @click="abrirMapa"
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

          <!-- Datos Adicionales -->
          <div class="section-title">
            <font-awesome-icon icon="info-circle" />
            Datos Adicionales
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Superficie Construida (m²)</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="licenciaData.sup_construida"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Superficie Autorizada (m²)</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="licenciaData.sup_autorizada"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Cajones</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.num_cajones"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Empleados</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.num_empleados"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Aforo</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="licenciaData.aforo"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Inversión</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="licenciaData.inversion"
              />
            </div>
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Horario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="licenciaData.rhorario"
                placeholder="Ej: Lun-Vie 9:00-18:00"
              />
            </div>
          </div>

          <!-- Saldo y Adeudo -->
          <div v-if="saldoLicencia" class="section-title">
            <font-awesome-icon icon="dollar-sign" />
            Saldo de la Licencia
          </div>

          <div v-if="saldoLicencia" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Total Adeudo</label>
              <div class="amount-display amount-danger">
                ${{ formatCurrency(saldoLicencia.total) }}
              </div>
            </div>
            <div class="form-group">
              <button
                class="btn-municipal-warning"
                @click="verDetalleAdeudo"
              >
                <font-awesome-icon icon="file-invoice-dollar" />
                Ver Detalle de Adeudo
              </button>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="button-group" style="margin-top: 30px;">
            <button
              class="btn-municipal-primary"
              @click="actualizarLicencia"
              :disabled="loading"
            >
              <font-awesome-icon icon="save" />
              Actualizar Licencia
            </button>
            <button
              class="btn-municipal-secondary"
              @click="cancelar"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Panel de Anuncio -->
      <div v-if="anuncioData && searchType === 'anuncio'" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="bullhorn" />
            Datos del Anuncio #{{ anuncioData.anuncio }}
            <span v-if="anuncioData.vigente !== 'V'" class="badge-danger">BAJA</span>
            <span v-else class="badge-success">VIGENTE</span>
          </h5>
          <div class="button-group">
            <button
              v-if="anuncioData.vigente !== 'V'"
              class="btn-municipal-success btn-sm"
              @click="reactivarAnuncio"
            >
              <font-awesome-icon icon="check-circle" />
              Reactivar
            </button>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Información del Anuncio -->
          <div class="section-title">
            <font-awesome-icon icon="bullhorn" />
            Información del Anuncio
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Anuncio <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="anuncioData.id_giro">
                <option value="">Seleccione tipo...</option>
                <option v-for="tipo in tiposAnuncio" :key="tipo.id_giro" :value="tipo.id_giro">
                  {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Licencia Asociada</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="anuncioData.id_licencia"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Otorgamiento</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="anuncioData.fecha_otorgamiento"
                readonly
              />
            </div>
          </div>

          <!-- Dimensiones -->
          <div class="section-title">
            <font-awesome-icon icon="ruler-combined" />
            Dimensiones del Anuncio
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Medida 1 (m)</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="anuncioData.medidas1"
                @input="calcularAreaAnuncio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Medida 2 (m)</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="anuncioData.medidas2"
                @input="calcularAreaAnuncio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Caras</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="anuncioData.num_caras"
                @input="calcularAreaAnuncio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Área Total (m²)</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="anuncioData.area_anuncio"
                readonly
              />
            </div>
          </div>

          <!-- Ubicación del Anuncio -->
          <div class="section-title">
            <font-awesome-icon icon="map-marker-alt" />
            Ubicación del Anuncio
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Calle</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="anuncioData.ubicacion"
                  readonly
                />
                <button class="btn-municipal-secondary btn-sm" @click="buscarCalleAnuncio">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Ext.</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="anuncioData.numext_ubic"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra Ext.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="anuncioData.letraext_ubic"
                maxlength="5"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Núm. Int.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="anuncioData.numint_ubic"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra Int.</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="anuncioData.letraint_ubic"
                maxlength="5"
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
                  v-model="anuncioData.colonia_ubic"
                />
                <button class="btn-municipal-secondary btn-sm" @click="buscarColoniaAnuncio">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Código Postal</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="anuncioData.cp"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="anuncioData.zona"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Subzona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="anuncioData.subzona"
                readonly
              />
            </div>
          </div>

          <!-- Texto del Anuncio -->
          <div class="form-row">
            <div class="form-group" style="flex: 3;">
              <label class="municipal-form-label">Texto del Anuncio</label>
              <textarea
                class="municipal-form-control"
                v-model="anuncioData.texto_anuncio"
                rows="3"
              ></textarea>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="button-group" style="margin-top: 30px;">
            <button
              class="btn-municipal-primary"
              @click="actualizarAnuncio"
              :disabled="loading"
            >
              <font-awesome-icon icon="save" />
              Actualizar Anuncio
            </button>
            <button
              class="btn-municipal-secondary"
              @click="cancelar"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
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
      :componentName="'modlicfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, computed } from 'vue'
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
  loadingMessage,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const searchType = ref('licencia')
const searchNumber = ref(null)
const licenciaData = ref(null)
const anuncioData = ref(null)
const saldoLicencia = ref(null)
const girosScian = ref([])
const actividades = ref([])
const tiposAnuncio = ref([])
const selectedCodGiro = ref('')
const coordenadasSeleccionadas = ref(null)
const sesionMapa = ref(null)

// Métodos de búsqueda
const buscar = async () => {
  if (!searchNumber.value) {
    showToast('warning', 'Por favor ingrese un número')
    return
  }

  // Limpiar datos anteriores
  licenciaData.value = null
  anuncioData.value = null
  saldoLicencia.value = null
  coordenadasSeleccionadas.value = null

  if (searchType.value === 'licencia') {
    await buscarLicencia()
  } else {
    await buscarAnuncio()
  }
}

const buscarLicencia = async () => {
  setLoading(true, 'Buscando licencia...')

  try {
    const response = await execute(
      'SP_MODLIC_BUSCAR_LICENCIA',
      'padron_licencias',
      [{ nombre: 'p_licencia', valor: searchNumber.value, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      licenciaData.value = response.result[0]

      // Cargar giros SCIAN si hay un giro
      if (licenciaData.value.cod_giro) {
        selectedCodGiro.value = licenciaData.value.cod_giro
        await loadGirosScian()
        await loadActividades(licenciaData.value.cod_giro)
      }

      // Cargar saldo
      await loadSaldoLicencia(licenciaData.value.id_licencia)

      showToast('success', 'Licencia encontrada')
    } else {
      showToast('error', 'No existe este número de licencia')
      licenciaData.value = null
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const buscarAnuncio = async () => {
  setLoading(true, 'Buscando anuncio...')

  try {
    const response = await execute(
      'SP_MODLIC_BUSCAR_ANUNCIO',
      'padron_licencias',
      [{ nombre: 'p_anuncio', valor: searchNumber.value, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      anuncioData.value = response.result[0]

      // Cargar tipos de anuncio
      await loadTiposAnuncio()

      showToast('success', 'Anuncio encontrado')
    } else {
      showToast('error', 'No existe este número de anuncio')
      anuncioData.value = null
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Cargar catálogos
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

const loadTiposAnuncio = async () => {
  try {
    const response = await execute(
      'SP_GET_TIPOS_ANUNCIO',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      tiposAnuncio.value = response.result
    }
  } catch (error) {
    console.error('Error cargando tipos de anuncio:', error)
  }
}

const loadSaldoLicencia = async (idLicencia) => {
  try {
    const response = await execute(
      'SP_GET_SALDO_LICENCIA',
      'padron_licencias',
      [{ nombre: 'p_id_licencia', valor: idLicencia, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      saldoLicencia.value = response.result[0]
    }
  } catch (error) {
    console.error('Error cargando saldo:', error)
  }
}

// Eventos de cambio
const onGiroScianChange = async () => {
  if (selectedCodGiro.value) {
    await loadActividades(selectedCodGiro.value)
    licenciaData.value.id_giro = null
  }
}

const onActividadChange = () => {
  const actividadSeleccionada = actividades.value.find(a => a.id_giro === licenciaData.value.id_giro)
  if (actividadSeleccionada) {
    licenciaData.value.actividad = actividadSeleccionada.descripcion
  }
}

const calcularAreaAnuncio = () => {
  if (anuncioData.value) {
    const m1 = parseFloat(anuncioData.value.medidas1) || 0
    const m2 = parseFloat(anuncioData.value.medidas2) || 0
    const caras = parseInt(anuncioData.value.num_caras) || 0
    anuncioData.value.area_anuncio = m1 * m2 * caras
  }
}

// Actualizar licencia
const actualizarLicencia = async () => {
  // Validaciones
  if (!licenciaData.value.id_giro) {
    showToast('warning', 'Debe seleccionar una actividad')
    return
  }

  // Solicitar firma
  const firmaResult = await solicitarFirma()
  if (!firmaResult.success) return

  setLoading(true, 'Actualizando licencia...')

  try {
    const response = await execute(
      'SP_MODLIC_ACTUALIZAR_LICENCIA',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_id_giro', valor: licenciaData.value.id_giro, tipo: 'integer' },
        { nombre: 'p_actividad', valor: licenciaData.value.actividad, tipo: 'string' },
        { nombre: 'p_propietario', valor: licenciaData.value.propietario, tipo: 'string' },
        { nombre: 'p_primer_ap', valor: licenciaData.value.primer_ap, tipo: 'string' },
        { nombre: 'p_segundo_ap', valor: licenciaData.value.segundo_ap, tipo: 'string' },
        { nombre: 'p_rfc', valor: licenciaData.value.rfc, tipo: 'string' },
        { nombre: 'p_curp', valor: licenciaData.value.curp, tipo: 'string' },
        { nombre: 'p_domicilio', valor: licenciaData.value.domicilio, tipo: 'string' },
        { nombre: 'p_numext_prop', valor: licenciaData.value.numext_prop, tipo: 'integer' },
        { nombre: 'p_numint_prop', valor: licenciaData.value.numint_prop, tipo: 'string' },
        { nombre: 'p_colonia_prop', valor: licenciaData.value.colonia_prop, tipo: 'string' },
        { nombre: 'p_telefono_prop', valor: licenciaData.value.telefono_prop, tipo: 'string' },
        { nombre: 'p_email', valor: licenciaData.value.email, tipo: 'string' },
        { nombre: 'p_ubicacion', valor: licenciaData.value.ubicacion, tipo: 'string' },
        { nombre: 'p_cvecalle', valor: licenciaData.value.cvecalle, tipo: 'integer' },
        { nombre: 'p_numext_ubic', valor: licenciaData.value.numext_ubic, tipo: 'integer' },
        { nombre: 'p_letraext_ubic', valor: licenciaData.value.letraext_ubic, tipo: 'string' },
        { nombre: 'p_numint_ubic', valor: licenciaData.value.numint_ubic, tipo: 'string' },
        { nombre: 'p_letraint_ubic', valor: licenciaData.value.letraint_ubic, tipo: 'string' },
        { nombre: 'p_colonia_ubic', valor: licenciaData.value.colonia_ubic, tipo: 'string' },
        { nombre: 'p_cp', valor: licenciaData.value.cp, tipo: 'integer' },
        { nombre: 'p_sup_construida', valor: licenciaData.value.sup_construida, tipo: 'double' },
        { nombre: 'p_sup_autorizada', valor: licenciaData.value.sup_autorizada, tipo: 'double' },
        { nombre: 'p_num_cajones', valor: licenciaData.value.num_cajones, tipo: 'integer' },
        { nombre: 'p_num_empleados', valor: licenciaData.value.num_empleados, tipo: 'integer' },
        { nombre: 'p_aforo', valor: licenciaData.value.aforo, tipo: 'integer' },
        { nombre: 'p_inversion', valor: licenciaData.value.inversion, tipo: 'double' },
        { nombre: 'p_rhorario', valor: licenciaData.value.rhorario, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      // Si hay coordenadas seleccionadas, actualizarlas
      if (coordenadasSeleccionadas.value && sesionMapa.value) {
        await actualizarCoordenadas()
      }

      // Recalcular saldos
      await recalcularSaldos(licenciaData.value.id_licencia)

      await Swal.fire({
        icon: 'success',
        title: 'Licencia Actualizada',
        text: 'La licencia se actualizó correctamente',
        confirmButtonColor: '#ea8215'
      })

      // Recargar datos
      await buscarLicencia()
    } else {
      showToast('error', 'Error al actualizar la licencia')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Actualizar anuncio
const actualizarAnuncio = async () => {
  // Validaciones
  if (!anuncioData.value.id_giro) {
    showToast('warning', 'Debe seleccionar un tipo de anuncio')
    return
  }

  // Solicitar firma
  const firmaResult = await solicitarFirma()
  if (!firmaResult.success) return

  setLoading(true, 'Actualizando anuncio...')

  try {
    const response = await execute(
      'SP_MODLIC_ACTUALIZAR_ANUNCIO',
      'padron_licencias',
      [
        { nombre: 'p_id_anuncio', valor: anuncioData.value.id_anuncio, tipo: 'integer' },
        { nombre: 'p_id_giro', valor: anuncioData.value.id_giro, tipo: 'integer' },
        { nombre: 'p_misma_forma', valor: anuncioData.value.misma_forma, tipo: 'string' },
        { nombre: 'p_medidas1', valor: anuncioData.value.medidas1, tipo: 'double' },
        { nombre: 'p_medidas2', valor: anuncioData.value.medidas2, tipo: 'double' },
        { nombre: 'p_num_caras', valor: anuncioData.value.num_caras, tipo: 'integer' },
        { nombre: 'p_ubicacion', valor: anuncioData.value.ubicacion, tipo: 'string' },
        { nombre: 'p_cvecalle', valor: anuncioData.value.cvecalle, tipo: 'integer' },
        { nombre: 'p_numext_ubic', valor: anuncioData.value.numext_ubic, tipo: 'integer' },
        { nombre: 'p_letraext_ubic', valor: anuncioData.value.letraext_ubic, tipo: 'string' },
        { nombre: 'p_numint_ubic', valor: anuncioData.value.numint_ubic, tipo: 'string' },
        { nombre: 'p_letraint_ubic', valor: anuncioData.value.letraint_ubic, tipo: 'string' },
        { nombre: 'p_colonia_ubic', valor: anuncioData.value.colonia_ubic, tipo: 'string' },
        { nombre: 'p_cp', valor: anuncioData.value.cp, tipo: 'integer' },
        { nombre: 'p_id_fabricante', valor: anuncioData.value.id_fabricante, tipo: 'integer' },
        { nombre: 'p_texto_anuncio', valor: anuncioData.value.texto_anuncio, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      // Recalcular adeudo del anuncio
      await recalcularAdeudoAnuncio(anuncioData.value.id_anuncio, anuncioData.value.id_licencia)

      await Swal.fire({
        icon: 'success',
        title: 'Anuncio Actualizado',
        text: 'El anuncio se actualizó correctamente',
        confirmButtonColor: '#ea8215'
      })

      // Recargar datos
      await buscarAnuncio()
    } else {
      showToast('error', 'Error al actualizar el anuncio')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Reactivar licencia/anuncio
const reactivarLicencia = () => {
  licenciaData.value.vigente = 'V'
  licenciaData.value.fecha_baja = null
  showToast('info', 'Licencia marcada para reactivación. Presione Actualizar para confirmar.')
}

const reactivarAnuncio = () => {
  anuncioData.value.vigente = 'V'
  anuncioData.value.fecha_baja = null
  showToast('info', 'Anuncio marcado para reactivación. Presione Actualizar para confirmar.')
}

// Recalcular saldos
const recalcularSaldos = async (idLicencia) => {
  try {
    await execute(
      'SP_CALC_SDOS_LIC',
      'padron_licencias',
      [{ nombre: 'p_id_licencia', valor: idLicencia, tipo: 'integer' }],
      'guadalajara'
    )
  } catch (error) {
    console.error('Error recalculando saldos:', error)
  }
}

const recalcularAdeudoAnuncio = async (idAnuncio, idLicencia) => {
  try {
    await execute(
      'SP_MODLIC_RECALCULAR_ADEUDO_ANUNCIO',
      'padron_licencias',
      [
        { nombre: 'p_id_anuncio', valor: idAnuncio, tipo: 'integer' },
        { nombre: 'p_id_licencia', valor: idLicencia, tipo: 'integer' }
      ],
      'guadalajara'
    )

    // Recalcular saldos totales de la licencia
    await recalcularSaldos(idLicencia)
  } catch (error) {
    console.error('Error recalculando adeudo anuncio:', error)
  }
}

// Mapa y coordenadas
const abrirMapa = async () => {
  if (!licenciaData.value?.licencia) {
    showToast('warning', 'No hay licencia cargada')
    return
  }

  // Solicitar firma para acceso al mapa
  const firmaResult = await solicitarFirmaUsuario()
  if (!firmaResult.success) return

  // Obtener sesión
  try {
    const response = await execute(
      'SP_GET_SESSION_ID',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.sessionid) {
      sesionMapa.value = response.result[0].sessionid

      // Limpiar sesión anterior
      await execute(
        'SP_MODLIC_LIMPIAR_SESION',
        'padron_licencias',
        [{ nombre: 'p_sesion_id', valor: sesionMapa.value, tipo: 'integer' }],
        'guadalajara'
      )

      // Abrir URL del mapa
      const urlMapa = `https://modulos.guadalajara.gob.mx/ubicacion/index.php?sesid=${sesionMapa.value}`
      window.open(urlMapa, '_blank')

      showToast('info', 'Mapa abierto. Seleccione la ubicación y regrese aquí.')

      // Iniciar polling para verificar si se seleccionó una ubicación
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
  }, 3000) // Verificar cada 3 segundos

  // Detener después de 5 minutos
  setTimeout(() => clearInterval(intervalo), 300000)
}

const actualizarCoordenadas = async () => {
  try {
    await execute(
      'SP_MODLIC_ACTUALIZAR_COORDENADAS',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: licenciaData.value.licencia, tipo: 'integer' },
        { nombre: 'p_sesion_id', valor: sesionMapa.value, tipo: 'integer' }
      ],
      'guadalajara'
    )
  } catch (error) {
    console.error('Error actualizando coordenadas:', error)
  }
}

// Solicitar firma
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
      if (!value) {
        return 'Debe ingresar su firma'
      }
    }
  })

  if (!firma) {
    return { success: false }
  }

  // Verificar firma
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

  // Verificar firma con modulos_id = 2 (ubicación)
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

// Búsquedas de catálogos (placeholders - implementar con modales)
const buscarGiroScian = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Giro SCIAN',
    text: 'Funcionalidad de búsqueda avanzada en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const buscarActividad = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Actividad',
    text: 'Funcionalidad de búsqueda avanzada en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const buscarCalle = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Calle',
    text: 'Funcionalidad de búsqueda de calles en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const buscarCalleAnuncio = async () => {
  await buscarCalle()
}

const buscarColonia = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Búsqueda de Colonia',
    text: 'Funcionalidad de búsqueda de colonias en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const buscarColoniaAnuncio = async () => {
  await buscarColonia()
}

const verDetalleAdeudo = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Detalle de Adeudo',
    text: 'Funcionalidad de detalle de adeudo en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

// Utilidades
const formatCurrency = (value) => {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

const cancelar = () => {
  licenciaData.value = null
  anuncioData.value = null
  saldoLicencia.value = null
  searchNumber.value = null
  coordenadasSeleccionadas.value = null
  sesionMapa.value = null
  showToast('info', 'Operación cancelada')
}

// Lifecycle
onMounted(async () => {
  await loadGirosScian()
})
</script>

<style scoped>
.radio-group {
  display: flex;
  gap: 15px;
  align-items: center;
}

.radio-label {
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
}

.radio-label input[type="radio"] {
  cursor: pointer;
}

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

.input-group {
  display: flex;
  gap: 5px;
}

.input-group .municipal-form-control {
  flex: 1;
}

.amount-display {
  font-size: 24px;
  font-weight: 700;
  padding: 15px;
  border-radius: 6px;
  text-align: center;
}

.amount-danger {
  background-color: #fee;
  color: #c53030;
  border: 2px solid #fc8181;
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
