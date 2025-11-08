<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Modificación de Trámites</h1>
        <p>Padrón de Licencias - Actualizar información de trámites en proceso</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="regresarConsulta">
          <font-awesome-icon icon="arrow-left" />
          Regresar a Consulta
        </button>
        <button class="btn-municipal-success" @click="nuevoTramite">
          <font-awesome-icon icon="plus" />
          Nuevo Trámite
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Acordeón de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleBusqueda">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Trámite
            <font-awesome-icon :icon="showBusqueda ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>
        <div class="municipal-card-body" v-show="showBusqueda">
          <div class="form-row">
            <div class="form-group" style="flex: 0 0 300px;">
              <label class="municipal-form-label">ID del Trámite *</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="searchId"
                placeholder="Ingrese el ID del trámite"
                @keyup.enter="buscarTramite"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscarTramite">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFormulario" v-if="tramiteEncontrado">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Alertas de estado -->
      <div v-if="tramiteEncontrado && !puedeModificar" class="alert-warning-box">
        <font-awesome-icon icon="exclamation-triangle" class="me-2" />
        <div>
          <strong>Este trámite NO puede modificarse - Solo Consulta.</strong>
          <p>{{ mensajeEstado }}</p>
        </div>
      </div>

      <!-- Acordeón de Información del Trámite -->
      <div v-if="tramiteEncontrado" class="municipal-card">
        <div class="municipal-card-header header-with-badge clickable-header" @click="toggleInfoTramite">
          <h5>
            <font-awesome-icon icon="file-alt" />
            Información del Trámite
            <font-awesome-icon :icon="showInfoTramite ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
          <div class="header-right">
            <span class="badge-info me-2">ID: {{ form.id_tramite }}</span>
            <span class="badge-secondary me-2">Folio: {{ form.folio || 'N/A' }}</span>
            <span :class="getBadgeEstatus(form.estatus)">{{ getNombreEstatus(form.estatus) }}</span>
          </div>
        </div>
        <div class="municipal-card-body" v-show="showInfoTramite">
          <div class="tramite-info-grid">
            <div class="info-item">
              <span class="info-label">Fecha de Captura:</span>
              <span class="info-value">{{ formatDate(form.feccap) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Capturista:</span>
              <span class="info-value">{{ form.capturista || 'N/A' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Tipo de Trámite:</span>
              <span class="info-value">{{ form.tipo_tramite === '1' ? 'Licencia' : 'Anuncio' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Bloqueado:</span>
              <span class="info-value">
                <span v-if="form.bloqueado === 1" class="badge-danger">Sí</span>
                <span v-else class="badge-success">No</span>
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Edición (solo si hay trámite y se puede modificar) -->
      <template v-if="tramiteEncontrado && puedeModificar">
        <!-- Tabs de Navegación -->
        <div class="tabs-container">
          <button
            class="tab-button"
            :class="{ active: activeTab === 'propietario' }"
            @click="setActiveTab('propietario')"
          >
            <font-awesome-icon icon="user" />
            Datos del Propietario
          </button>
          <button
            class="tab-button"
            :class="{ active: activeTab === 'domicilioFiscal' }"
            @click="setActiveTab('domicilioFiscal')"
          >
            <font-awesome-icon icon="home" />
            Domicilio Fiscal
          </button>
          <button
            class="tab-button"
            :class="{ active: activeTab === 'ubicacionNegocio' }"
            @click="setActiveTab('ubicacionNegocio')"
          >
            <font-awesome-icon icon="map-marker-alt" />
            Ubicación del Negocio
          </button>
          <button
            class="tab-button"
            :class="{ active: activeTab === 'giroActividad' }"
            @click="setActiveTab('giroActividad')"
          >
            <font-awesome-icon icon="briefcase" />
            Giro y Actividad
          </button>
          <button
            class="tab-button"
            :class="{ active: activeTab === 'datosTecnicos' }"
            @click="setActiveTab('datosTecnicos')"
          >
            <font-awesome-icon icon="ruler-combined" />
            Datos Técnicos
          </button>
          <button
            class="tab-button"
            :class="{ active: activeTab === 'observaciones' }"
            @click="setActiveTab('observaciones')"
          >
            <font-awesome-icon icon="sticky-note" />
            Observaciones
          </button>
        </div>

        <!-- Contenido de Tabs -->
        <!-- Tab 1: Datos del Propietario -->
        <div class="municipal-card tab-content" v-show="activeTab === 'propietario'">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="user" />
              Datos del Propietario
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Primer Apellido *</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.primer_ap"
                  maxlength="80"
                  @input="form.primer_ap = form.primer_ap?.toUpperCase()"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Segundo Apellido</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.segundo_ap"
                  maxlength="80"
                  @input="form.segundo_ap = form.segundo_ap?.toUpperCase()"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Nombre(s) *</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.propietario"
                  maxlength="80"
                  @input="form.propietario = form.propietario?.toUpperCase()"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">RFC *</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.rfc"
                  maxlength="13"
                  placeholder="XXXX000000XXX"
                  @input="form.rfc = form.rfc?.toUpperCase()"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">CURP *</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.curp"
                  maxlength="18"
                  placeholder="XXXX000000XXXXXX00"
                  @input="form.curp = form.curp?.toUpperCase()"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Teléfono</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.telefono_prop"
                  maxlength="30"
                  placeholder="33-0000-0000"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Email</label>
                <input
                  type="email"
                  class="municipal-form-control"
                  v-model="form.email"
                  maxlength="50"
                  placeholder="ejemplo@dominio.com"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Tab 2: Domicilio Fiscal -->
        <div class="municipal-card tab-content" v-show="activeTab === 'domicilioFiscal'">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="home" />
              Domicilio Fiscal
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Calle/Domicilio</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.domicilio"
                  maxlength="50"
                />
              </div>
              <div class="form-group" style="flex: 0 0 150px;">
                <label class="municipal-form-label">Núm. Ext.</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.numext_prop"
                />
              </div>
              <div class="form-group" style="flex: 0 0 100px;">
                <label class="municipal-form-label">Núm. Int.</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.numint_prop"
                  maxlength="5"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Colonia</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.colonia_prop"
                  maxlength="25"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Tab 3: Ubicación del Negocio -->
        <div class="municipal-card tab-content" v-show="activeTab === 'ubicacionNegocio'">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación del Negocio
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Calle *</label>
                <div class="input-with-button">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="form.ubicacion"
                    readonly
                  />
                  <button class="btn-municipal-primary" @click="openCalleModal">
                    <font-awesome-icon icon="search" />
                  </button>
                </div>
              </div>
              <div class="form-group" style="flex: 0 0 150px;">
                <label class="municipal-form-label">Núm. Ext. *</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.numext_ubic"
                />
              </div>
              <div class="form-group" style="flex: 0 0 100px;">
                <label class="municipal-form-label">Letra Ext.</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.letraext_ubic"
                  maxlength="3"
                  @input="form.letraext_ubic = form.letraext_ubic?.toUpperCase()"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 0 0 100px;">
                <label class="municipal-form-label">Núm. Int.</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.numint_ubic"
                  maxlength="5"
                />
              </div>
              <div class="form-group" style="flex: 0 0 100px;">
                <label class="municipal-form-label">Letra Int.</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.letraint_ubic"
                  maxlength="3"
                  @input="form.letraint_ubic = form.letraint_ubic?.toUpperCase()"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Colonia *</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.colonia_ubic"
                  maxlength="25"
                />
              </div>
              <div class="form-group" style="flex: 0 0 120px;">
                <label class="municipal-form-label">Código Postal</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.cp"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Especificación de Ubicación</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.espubic"
                  maxlength="60"
                  placeholder="Ej: Entre calles, referencias, etc."
                />
              </div>
              <div class="form-group" style="flex: 0 0 100px;">
                <label class="municipal-form-label">Zona *</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.zona"
                  readonly
                  disabled
                />
              </div>
              <div class="form-group" style="flex: 0 0 120px;">
                <label class="municipal-form-label">Subzona *</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.subzona"
                  readonly
                  disabled
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Tab 4: Giro y Actividad -->
        <div class="municipal-card tab-content" v-show="activeTab === 'giroActividad'">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="briefcase" />
              Giro y Actividad
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Giro SCIAN *</label>
                <div class="input-with-button">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="giroSeleccionado"
                    readonly
                  />
                  <button class="btn-municipal-primary" @click="openGiroModal">
                    <font-awesome-icon icon="search" />
                  </button>
                </div>
              </div>
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Actividad Específica *</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.actividad"
                  maxlength="130"
                  @input="form.actividad = form.actividad?.toUpperCase()"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Tab 5: Datos Técnicos -->
        <div class="municipal-card tab-content" v-show="activeTab === 'datosTecnicos'">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="ruler-combined" />
              Datos Técnicos del Establecimiento
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Superficie Construida (m²)</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.sup_construida"
                  step="0.01"
                  min="0"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Superficie Autorizada (m²)</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.sup_autorizada"
                  step="0.01"
                  min="0"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Núm. de Cajones</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.num_cajones"
                  min="0"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Núm. de Empleados</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.num_empleados"
                  min="0"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Aforo (Personas)</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.aforo"
                  min="0"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Inversión ($)</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.inversion"
                  step="0.01"
                  min="0"
                />
              </div>
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Horario de Operación</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="form.rhorario"
                  maxlength="50"
                  placeholder="Ej: Lunes a Viernes 9:00 - 18:00"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Tab 6: Observaciones -->
        <div class="municipal-card tab-content" v-show="activeTab === 'observaciones'">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="sticky-note" />
              Observaciones
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-group">
              <label class="municipal-form-label">Observaciones Adicionales</label>
              <textarea
                class="municipal-form-control"
                v-model="form.observaciones"
                rows="4"
                maxlength="1000"
                placeholder="Agregue observaciones o notas importantes sobre este trámite..."
              ></textarea>
              <div class="char-counter">
                {{ form.observaciones?.length || 0 }} / 1000 caracteres
              </div>
            </div>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="municipal-card">
          <div class="municipal-card-body">
            <div class="button-group">
              <button class="btn-municipal-success" @click="confirmarActualizacion">
                <font-awesome-icon icon="save" />
                Actualizar Trámite
              </button>
              <button class="btn-municipal-secondary" @click="limpiarFormulario">
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </div>
        </div>
      </template>

      <!-- Vista de Solo Lectura (cuando no se puede modificar) -->
      <template v-if="tramiteEncontrado && !puedeModificar">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="eye" />
              Datos del Trámite (Solo Consulta)
            </h5>
          </div>
          <div class="municipal-card-body">
            <!-- Datos del Propietario -->
            <div class="readonly-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" />
                Datos del Propietario
              </h6>
              <div class="readonly-grid">
                <div class="readonly-item">
                  <label class="readonly-label">Nombre Completo:</label>
                  <div class="readonly-value">{{ form.primer_ap }} {{ form.segundo_ap }} {{ form.propietario }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">RFC:</label>
                  <div class="readonly-value">{{ form.rfc || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">CURP:</label>
                  <div class="readonly-value">{{ form.curp || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Teléfono:</label>
                  <div class="readonly-value">{{ form.telefono_prop || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Email:</label>
                  <div class="readonly-value">{{ form.email || 'N/A' }}</div>
                </div>
              </div>
            </div>

            <!-- Domicilio Fiscal -->
            <div class="readonly-section">
              <h6 class="section-title">
                <font-awesome-icon icon="home" />
                Domicilio Fiscal
              </h6>
              <div class="readonly-grid">
                <div class="readonly-item">
                  <label class="readonly-label">Domicilio:</label>
                  <div class="readonly-value">{{ form.domicilio || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Número Exterior:</label>
                  <div class="readonly-value">{{ form.numext_prop || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Número Interior:</label>
                  <div class="readonly-value">{{ form.numint_prop || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Colonia:</label>
                  <div class="readonly-value">{{ form.colonia_prop || 'N/A' }}</div>
                </div>
              </div>
            </div>

            <!-- Ubicación del Negocio -->
            <div class="readonly-section">
              <h6 class="section-title">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación del Negocio
              </h6>
              <div class="readonly-grid">
                <div class="readonly-item">
                  <label class="readonly-label">Calle:</label>
                  <div class="readonly-value">{{ form.ubicacion || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Número Exterior:</label>
                  <div class="readonly-value">{{ form.numext_ubic || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Letra Exterior:</label>
                  <div class="readonly-value">{{ form.letraext_ubic || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Número Interior:</label>
                  <div class="readonly-value">{{ form.numint_ubic || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Letra Interior:</label>
                  <div class="readonly-value">{{ form.letraint_ubic || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Colonia:</label>
                  <div class="readonly-value">{{ form.colonia_ubic || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Espacio Público:</label>
                  <div class="readonly-value">{{ form.espubic || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Código Postal:</label>
                  <div class="readonly-value">{{ form.cp || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Zona:</label>
                  <div class="readonly-value">{{ form.zona || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Subzona:</label>
                  <div class="readonly-value">{{ form.subzona || 'N/A' }}</div>
                </div>
              </div>
            </div>

            <!-- Giro y Actividad -->
            <div class="readonly-section">
              <h6 class="section-title">
                <font-awesome-icon icon="briefcase" />
                Giro y Actividad
              </h6>
              <div class="readonly-grid">
                <div class="readonly-item full-width">
                  <label class="readonly-label">ID Giro:</label>
                  <div class="readonly-value">{{ form.id_giro || 'N/A' }}</div>
                </div>
                <div class="readonly-item full-width">
                  <label class="readonly-label">Actividad:</label>
                  <div class="readonly-value">{{ form.actividad || 'N/A' }}</div>
                </div>
              </div>
            </div>

            <!-- Datos Técnicos -->
            <div class="readonly-section">
              <h6 class="section-title">
                <font-awesome-icon icon="ruler-combined" />
                Datos Técnicos
              </h6>
              <div class="readonly-grid">
                <div class="readonly-item">
                  <label class="readonly-label">Superficie Construida (m²):</label>
                  <div class="readonly-value">{{ form.sup_construida || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Superficie Autorizada (m²):</label>
                  <div class="readonly-value">{{ form.sup_autorizada || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Número de Cajones:</label>
                  <div class="readonly-value">{{ form.num_cajones || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Número de Empleados:</label>
                  <div class="readonly-value">{{ form.num_empleados || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Aforo:</label>
                  <div class="readonly-value">{{ form.aforo || 'N/A' }}</div>
                </div>
                <div class="readonly-item">
                  <label class="readonly-label">Inversión ($):</label>
                  <div class="readonly-value">{{ formatCurrency(form.inversion) }}</div>
                </div>
                <div class="readonly-item full-width">
                  <label class="readonly-label">Horario:</label>
                  <div class="readonly-value">{{ form.rhorario || 'N/A' }}</div>
                </div>
              </div>
            </div>

            <!-- Observaciones -->
            <div class="readonly-section" v-if="form.observaciones">
              <h6 class="section-title">
                <font-awesome-icon icon="sticky-note" />
                Observaciones
              </h6>
              <div class="readonly-item full-width">
                <div class="readonly-value">{{ form.observaciones }}</div>
              </div>
            </div>
          </div>
        </div>
      </template>

      <!-- Empty State -->
      <div v-if="!tramiteEncontrado" class="municipal-card">
        <div class="municipal-card-body">
          <div class="empty-state-content">
            <div class="empty-state-icon">
              <font-awesome-icon icon="search" />
            </div>
            <p class="empty-state-text">No hay trámite seleccionado</p>
            <p class="empty-state-hint">Busque un trámite por su ID para comenzar</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Búsqueda de Giros -->
    <Modal :show="showGiroModal" @close="closeGiroModal" size="xl">
      <template #header>
        <h5>
          <font-awesome-icon icon="search" class="me-2" />
          Búsqueda de Giros SCIAN
        </h5>
      </template>
      <template #body>
        <div class="form-group mb-3">
          <input
            type="text"
            class="municipal-form-control"
            v-model="giroSearch"
            placeholder="Buscar por descripción... (mínimo 3 caracteres)"
            @input="buscarGiros"
          />
        </div>

        <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 80px;">ID</th>
                <th>Descripción</th>
                <th style="width: 80px;">Tipo</th>
                <th style="width: 100px;">Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="giro in girosEncontrados" :key="giro.id_giro" class="clickable-row">
                <td>{{ giro.id_giro }}</td>
                <td>{{ giro.descripcion }}</td>
                <td style="text-align: center;">
                  <span class="badge-primary" v-if="giro.tipo === 'L'">Lic</span>
                  <span class="badge-secondary" v-else>Anun</span>
                </td>
                <td style="text-align: center;">
                  <button class="btn-municipal-sm btn-municipal-primary" @click="seleccionarGiro(giro)">
                    Seleccionar
                  </button>
                </td>
              </tr>
              <tr v-if="girosEncontrados.length === 0">
                <td colspan="4" class="text-center">
                  <div class="empty-state-hint" style="padding: 20px;">
                    {{ giroSearch.length < 3 ? 'Ingrese al menos 3 caracteres para buscar' : 'No se encontraron giros' }}
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeGiroModal">
          Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal de Búsqueda de Calles -->
    <Modal :show="showCalleModal" @close="closeCalleModal" size="lg">
      <template #header>
        <h5>
          <font-awesome-icon icon="search" class="me-2" />
          Búsqueda de Calles
        </h5>
      </template>
      <template #body>
        <div class="form-group mb-3">
          <input
            type="text"
            class="municipal-form-control"
            v-model="calleSearch"
            placeholder="Buscar calle... (mínimo 3 caracteres)"
            @input="buscarCalles"
          />
        </div>

        <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Calle</th>
                <th style="width: 80px;">Zona</th>
                <th style="width: 100px;">Subzona</th>
                <th style="width: 100px;">Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="calle in callesEncontradas" :key="calle.cvecalle" class="clickable-row">
                <td>{{ calle.calle }}</td>
                <td style="text-align: center;">{{ calle.zona }}</td>
                <td style="text-align: center;">{{ calle.subzona }}</td>
                <td style="text-align: center;">
                  <button class="btn-municipal-sm btn-municipal-primary" @click="seleccionarCalle(calle)">
                    Seleccionar
                  </button>
                </td>
              </tr>
              <tr v-if="callesEncontradas.length === 0">
                <td colspan="4" class="text-center">
                  <div class="empty-state-hint" style="padding: 20px;">
                    {{ calleSearch.length < 3 ? 'Ingrese al menos 3 caracteres para buscar' : 'No se encontraron calles' }}
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeCalleModal">
          Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal de Ayuda -->
    <Modal :show="showDocumentation" @close="closeDocumentation" size="lg">
      <template #header>
        <h5>
          <font-awesome-icon icon="question-circle" class="me-2" />
          Ayuda - Modificación de Trámites
        </h5>
      </template>
      <template #body>
        <h6>Descripción del Módulo</h6>
        <p>
          Este módulo permite modificar la información de trámites en proceso (solicitudes de licencias o anuncios
          que aún no han sido aprobados). Puede corregir datos del solicitante, actualizar ubicaciones,
          modificar giros o actividades, y ajustar datos técnicos.
        </p>

        <h6>¿Qué trámites se pueden modificar?</h6>
        <ul>
          <li><strong>En Proceso (T):</strong> Trámites que están en revisión</li>
          <li><strong>Rechazados (R):</strong> Trámites que fueron rechazados y necesitan corrección</li>
        </ul>

        <h6>¿Qué trámites NO se pueden modificar?</h6>
        <ul>
          <li><strong>Autorizados (A):</strong> Trámites ya aprobados (usar módulo de modificación de licencias)</li>
          <li><strong>Cancelados (C):</strong> Trámites cancelados</li>
        </ul>

        <h6>Campos Obligatorios</h6>
        <ul>
          <li>Primer Apellido y Nombre(s) del propietario</li>
          <li>RFC (formato: XXXX000000XXX)</li>
          <li>CURP (formato: XXXX000000XXXXXX00)</li>
          <li>Calle de ubicación del negocio</li>
          <li>Número exterior de ubicación</li>
          <li>Colonia de ubicación</li>
          <li>Giro SCIAN y Actividad específica</li>
        </ul>

        <h6>Recomendaciones</h6>
        <ul>
          <li>Verifique que todos los datos sean correctos antes de actualizar</li>
          <li>El RFC y CURP deben cumplir con el formato oficial</li>
          <li>Use el botón de búsqueda para seleccionar giros y calles del catálogo</li>
          <li>La zona y subzona se asignan automáticamente al seleccionar la calle</li>
          <li>Agregue observaciones si el cambio es significativo</li>
          <li>Los cambios quedan registrados con usuario y fecha de modificación</li>
        </ul>

        <h6>Diferencias importantes</h6>
        <p>
          <strong>Modificación de Trámites vs Modificación de Licencias:</strong>
        </p>
        <ul>
          <li>Este módulo: Solicitudes en proceso (NO aprobadas)</li>
          <li>modlicfrm: Registros ya autorizados y vigentes</li>
        </ul>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeDocumentation">
          Cerrar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { handleError, showToast } = useLicenciasErrorHandler()
const route = useRoute()
const router = useRouter()

// Estado del componente
const searchId = ref(null)
const tramiteEncontrado = ref(false)
const tramiteOriginal = ref(null)
const giroSeleccionado = ref('')
const showDocumentation = ref(false)

// Acordeones de búsqueda e info
const showBusqueda = ref(true)
const showInfoTramite = ref(true)

// Tab activa
const activeTab = ref('propietario')

// Formulario
const form = ref({
  id_tramite: null,
  // Propietario
  primer_ap: '',
  segundo_ap: '',
  propietario: '',
  rfc: '',
  curp: '',
  telefono_prop: '',
  email: '',
  // Domicilio fiscal
  domicilio: '',
  numext_prop: null,
  numint_prop: '',
  colonia_prop: '',
  // Ubicación negocio
  cvecalle: null,
  ubicacion: '',
  numext_ubic: null,
  numint_ubic: '',
  letraext_ubic: '',
  letraint_ubic: '',
  colonia_ubic: '',
  espubic: '',
  zona: null,
  subzona: null,
  cp: null,
  // Giro y actividad
  id_giro: null,
  actividad: '',
  // Datos técnicos
  sup_construida: null,
  sup_autorizada: null,
  num_cajones: null,
  num_empleados: null,
  aforo: null,
  inversion: null,
  rhorario: '',
  // Observaciones
  observaciones: '',
  // Control
  estatus: '',
  tipo_tramite: '',
  folio: null,
  feccap: null,
  capturista: '',
  bloqueado: 0,
  dictamen: 0
})

// Búsqueda de giros
const showGiroModal = ref(false)
const giroSearch = ref('')
const girosEncontrados = ref([])

// Búsqueda de calles
const showCalleModal = ref(false)
const calleSearch = ref('')
const callesEncontradas = ref([])

// Computed
const puedeModificar = computed(() => {
  return form.value.estatus === 'T' || form.value.estatus === 'R'
})

const mensajeEstado = computed(() => {
  if (form.value.estatus === 'A') {
    return 'Este trámite ya fue AUTORIZADO. Use el módulo de modificación de licencias (modlicfrm).'
  }
  if (form.value.estatus === 'C') {
    return 'Este trámite fue CANCELADO y no puede modificarse.'
  }
  return 'El trámite no se encuentra en un estado modificable.'
})

// Métodos
const buscarTramite = async () => {
  if (!searchId.value) {
    Swal.fire({
      icon: 'warning',
      title: 'Campo Requerido',
      text: 'Por favor ingrese el ID del trámite',
      confirmButtonText: 'Entendido',
      confirmButtonColor: '#ea8215',
      timer: 3000
    })
    return
  }

  showLoading('Buscando trámite...')
  const startTime = performance.now()

  try {
    // Buscar trámite
    const response = await execute(
      'sp_get_tramite_by_id',
      'padron_licencias',
      [{ nombre: 'p_id_tramite', valor: searchId.value, tipo: 'integer' }],
      '',      // tenant
      null,    // pagination
      'comun'  // esquema
    )

    if (!response || !response.result || response.result.length === 0) {
      hideLoading()
      Swal.fire({
        icon: 'error',
        title: 'No Encontrado',
        text: `No se encontró un trámite con ID ${searchId.value}`,
        confirmButtonText: 'Entendido',
        confirmButtonColor: '#ea8215',
        timer: 3000
      })
      return
    }

    const tramite = response.result[0]
    tramiteOriginal.value = { ...tramite }

    // Cargar datos al formulario
    form.value = {
      id_tramite: tramite.id_tramite,
      primer_ap: tramite.primer_ap || '',
      segundo_ap: tramite.segundo_ap || '',
      propietario: tramite.propietario || '',
      rfc: tramite.rfc || '',
      curp: tramite.curp || '',
      telefono_prop: tramite.telefono_prop || '',
      email: tramite.email || '',
      domicilio: tramite.domicilio || '',
      numext_prop: tramite.numext_prop,
      numint_prop: tramite.numint_prop || '',
      colonia_prop: tramite.colonia_prop || '',
      cvecalle: tramite.cvecalle,
      ubicacion: tramite.ubicacion || '',
      numext_ubic: tramite.numext_ubic,
      numint_ubic: tramite.numint_ubic || '',
      letraext_ubic: tramite.letraext_ubic || '',
      letraint_ubic: tramite.letraint_ubic || '',
      colonia_ubic: tramite.colonia_ubic || '',
      espubic: tramite.espubic || '',
      zona: tramite.zona,
      subzona: tramite.subzona,
      cp: tramite.cp,
      id_giro: tramite.id_giro,
      actividad: tramite.actividad || '',
      sup_construida: tramite.sup_construida,
      sup_autorizada: tramite.sup_autorizada,
      num_cajones: tramite.num_cajones,
      num_empleados: tramite.num_empleados,
      aforo: tramite.aforo,
      inversion: tramite.inversion,
      rhorario: tramite.rhorario || '',
      observaciones: tramite.observaciones || '',
      estatus: tramite.estatus || '',
      tipo_tramite: tramite.tipo_tramite || '',
      folio: tramite.folio,
      feccap: tramite.feccap,
      capturista: tramite.capturista || '',
      bloqueado: tramite.bloqueado || 0,
      dictamen: tramite.dictamen || 0
    }

    // Buscar giro si existe
    if (tramite.id_giro) {
      await cargarGiro(tramite.id_giro)
    }

    tramiteEncontrado.value = true

    // Auto-colapsar acordeones al cargar trámite
    showInfoTramite.value = false
    showBusqueda.value = false

    const endTime = performance.now()
    const duration = endTime - startTime
    const durationText = duration < 1000
      ? `${Math.round(duration)}ms`
      : `${(duration / 1000).toFixed(2)}s`

    showToast('success', `Trámite cargado - Folio: ${tramite.folio || 'N/A'}`, durationText)

  } catch (error) {
    console.error('Error al buscar trámite:', error)
    handleError(error)
  } finally {
    hideLoading()
  }
}

const cargarGiro = async (idGiro) => {
  try {
    const response = await execute(
      'sp_get_giro_by_id',
      'padron_licencias',
      [{ nombre: 'p_id_giro', valor: idGiro, tipo: 'integer' }],
      '',      // tenant
      null,    // pagination
      'comun'  // esquema
    )

    if (response && response.result && response.result.length > 0) {
      const giro = response.result[0]
      giroSeleccionado.value = `[${giro.id_giro}] ${giro.descripcion}`
    }
  } catch (error) {
    console.error('Error al cargar giro:', error)
  }
}

const limpiarFormulario = () => {
  searchId.value = null
  tramiteEncontrado.value = false
  tramiteOriginal.value = null
  giroSeleccionado.value = ''
  form.value = {
    id_tramite: null,
    primer_ap: '',
    segundo_ap: '',
    propietario: '',
    rfc: '',
    curp: '',
    telefono_prop: '',
    email: '',
    domicilio: '',
    numext_prop: null,
    numint_prop: '',
    colonia_prop: '',
    cvecalle: null,
    ubicacion: '',
    numext_ubic: null,
    numint_ubic: '',
    letraext_ubic: '',
    letraint_ubic: '',
    colonia_ubic: '',
    espubic: '',
    zona: null,
    subzona: null,
    cp: null,
    id_giro: null,
    actividad: '',
    sup_construida: null,
    sup_autorizada: null,
    num_cajones: null,
    num_empleados: null,
    aforo: null,
    inversion: null,
    rhorario: '',
    observaciones: '',
    estatus: '',
    tipo_tramite: '',
    folio: null,
    feccap: null,
    capturista: '',
    bloqueado: 0,
    dictamen: 0
  }

  // Resetear acordeones
  showBusqueda.value = true
  showInfoTramite.value = true
}

const confirmarActualizacion = async () => {
  // Validaciones
  if (!form.value.primer_ap || !form.value.propietario) {
    Swal.fire({
      icon: 'warning',
      title: 'Campos Requeridos',
      text: 'Por favor complete el primer apellido y nombre del propietario',
      confirmButtonText: 'Entendido',
      confirmButtonColor: '#ea8215',
      timer: 3000
    })
    return
  }

  if (!form.value.rfc || !form.value.curp) {
    Swal.fire({
      icon: 'warning',
      title: 'Campos Requeridos',
      text: 'Por favor complete el RFC y CURP',
      confirmButtonText: 'Entendido',
      confirmButtonColor: '#ea8215',
      timer: 3000
    })
    return
  }

  if (!form.value.ubicacion || !form.value.numext_ubic || !form.value.colonia_ubic) {
    Swal.fire({
      icon: 'warning',
      title: 'Campos Requeridos',
      text: 'Por favor complete la ubicación del negocio (calle, número exterior y colonia)',
      confirmButtonText: 'Entendido',
      confirmButtonColor: '#ea8215',
      timer: 3000
    })
    return
  }

  if (!form.value.id_giro || !form.value.actividad) {
    Swal.fire({
      icon: 'warning',
      title: 'Campos Requeridos',
      text: 'Por favor seleccione el giro y actividad',
      confirmButtonText: 'Entendido',
      confirmButtonColor: '#ea8215',
      timer: 3000
    })
    return
  }

  // Confirmar actualización
  const result = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Actualización',
    html: `
      <div style="text-align: left; margin-top: 15px;">
        <p><strong>¿Está seguro de actualizar el trámite?</strong></p>
        <br>
        <strong>ID Trámite:</strong> ${form.value.id_tramite}<br>
        <strong>Folio:</strong> ${form.value.folio || 'N/A'}<br>
        <strong>Propietario:</strong> ${form.value.primer_ap} ${form.value.segundo_ap} ${form.value.propietario}<br>
        <strong>RFC:</strong> ${form.value.rfc}<br>
      </div>
    `,
    showCancelButton: true,
    confirmButtonText: 'Sí, Actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#6cca98',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando trámite...')

  try {
    const response = await execute(
      'sp_update_tramite',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: form.value.id_tramite, tipo: 'integer' },
        { nombre: 'p_primer_ap', valor: form.value.primer_ap, tipo: 'string' },
        { nombre: 'p_segundo_ap', valor: form.value.segundo_ap, tipo: 'string' },
        { nombre: 'p_propietario', valor: form.value.propietario, tipo: 'string' },
        { nombre: 'p_rfc', valor: form.value.rfc, tipo: 'string' },
        { nombre: 'p_curp', valor: form.value.curp, tipo: 'string' },
        { nombre: 'p_telefono_prop', valor: form.value.telefono_prop, tipo: 'string' },
        { nombre: 'p_email', valor: form.value.email, tipo: 'string' },
        { nombre: 'p_domicilio', valor: form.value.domicilio, tipo: 'string' },
        { nombre: 'p_numext_prop', valor: form.value.numext_prop, tipo: 'integer' },
        { nombre: 'p_numint_prop', valor: form.value.numint_prop, tipo: 'string' },
        { nombre: 'p_colonia_prop', valor: form.value.colonia_prop, tipo: 'string' },
        { nombre: 'p_cvecalle', valor: form.value.cvecalle, tipo: 'integer' },
        { nombre: 'p_ubicacion', valor: form.value.ubicacion, tipo: 'string' },
        { nombre: 'p_numext_ubic', valor: form.value.numext_ubic, tipo: 'integer' },
        { nombre: 'p_numint_ubic', valor: form.value.numint_ubic, tipo: 'string' },
        { nombre: 'p_letraext_ubic', valor: form.value.letraext_ubic, tipo: 'string' },
        { nombre: 'p_letraint_ubic', valor: form.value.letraint_ubic, tipo: 'string' },
        { nombre: 'p_colonia_ubic', valor: form.value.colonia_ubic, tipo: 'string' },
        { nombre: 'p_espubic', valor: form.value.espubic, tipo: 'string' },
        { nombre: 'p_zona', valor: form.value.zona, tipo: 'integer' },
        { nombre: 'p_subzona', valor: form.value.subzona, tipo: 'integer' },
        { nombre: 'p_cp', valor: form.value.cp, tipo: 'integer' },
        { nombre: 'p_id_giro', valor: form.value.id_giro, tipo: 'integer' },
        { nombre: 'p_actividad', valor: form.value.actividad, tipo: 'string' },
        { nombre: 'p_sup_construida', valor: form.value.sup_construida, tipo: 'numeric' },
        { nombre: 'p_sup_autorizada', valor: form.value.sup_autorizada, tipo: 'numeric' },
        { nombre: 'p_num_cajones', valor: form.value.num_cajones, tipo: 'integer' },
        { nombre: 'p_num_empleados', valor: form.value.num_empleados, tipo: 'integer' },
        { nombre: 'p_aforo', valor: form.value.aforo, tipo: 'integer' },
        { nombre: 'p_inversion', valor: form.value.inversion, tipo: 'numeric' },
        { nombre: 'p_rhorario', valor: form.value.rhorario, tipo: 'string' },
        { nombre: 'p_observaciones', valor: form.value.observaciones, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      '',      // tenant
      null,    // pagination
      'comun'  // esquema
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      // El SP devuelve un JSON como string, necesitamos parsearlo
      let resultado = response.result[0]

      // Si resultado tiene una propiedad sp_update_tramite (el nombre del SP), parsearlo
      if (resultado.sp_update_tramite) {
        resultado = typeof resultado.sp_update_tramite === 'string'
          ? JSON.parse(resultado.sp_update_tramite)
          : resultado.sp_update_tramite
      }

      if (resultado.success) {
        // Guardar info antes de limpiar
        const tramiteInfo = {
          id: form.value.id_tramite,
          folio: form.value.folio,
          propietario: `${form.value.primer_ap} ${form.value.segundo_ap} ${form.value.propietario}`
        }

        await Swal.fire({
          icon: 'success',
          title: '✅ Trámite Actualizado Correctamente',
          html: `
            <div style="text-align: left; margin-top: 15px; padding: 15px; background: #f0f9ff; border-radius: 8px; border-left: 4px solid #6cca98;">
              <p style="margin: 8px 0;"><strong>ID Trámite:</strong> ${tramiteInfo.id}</p>
              <p style="margin: 8px 0;"><strong>Folio:</strong> ${tramiteInfo.folio || 'N/A'}</p>
              <p style="margin: 8px 0;"><strong>Propietario:</strong> ${tramiteInfo.propietario}</p>
              <p style="margin: 15px 0 8px 0; color: #059669; font-weight: 600;">
                ✓ Todos los cambios han sido guardados exitosamente
              </p>
            </div>
          `,
          confirmButtonText: 'Entendido',
          confirmButtonColor: '#6cca98',
          width: '500px'
        })

        limpiarFormulario()
      } else {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message || 'No se pudo actualizar el trámite',
          confirmButtonText: 'Entendido',
          confirmButtonColor: '#dc3545'
        })
      }
    } else {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se recibió respuesta del servidor',
        confirmButtonText: 'Entendido',
        confirmButtonColor: '#dc3545'
      })
    }

  } catch (error) {
    hideLoading()
    console.error('Error al actualizar trámite:', error)
    handleError(error)
  }
}

const setActiveTab = (tab) => {
  activeTab.value = tab
}

const toggleBusqueda = () => {
  showBusqueda.value = !showBusqueda.value
}

const toggleInfoTramite = () => {
  showInfoTramite.value = !showInfoTramite.value
}

const regresarConsulta = () => {
  router.push('/padron-licencias/consulta-tramites')
}

const nuevoTramite = () => {
  // Navegar a la página de registro de solicitud
  router.push('/padron-licencias/registro-solicitud')
}

// Funciones de búsqueda de giros
const openGiroModal = () => {
  showGiroModal.value = true
  giroSearch.value = ''
  girosEncontrados.value = []
}

const closeGiroModal = () => {
  showGiroModal.value = false
}

const buscarGiros = async () => {
  if (giroSearch.value.length < 3) {
    girosEncontrados.value = []
    return
  }

  try {
    const response = await execute(
      'sp_get_giros_search',
      'padron_licencias',
      [
        { nombre: 'p_busqueda', valor: giroSearch.value, tipo: 'string' },
        { nombre: 'p_tipo', valor: 'L', tipo: 'string' },
        { nombre: 'p_limit', valor: 50, tipo: 'integer' }
      ],
      '',      // tenant
      null,    // pagination
      'comun'  // esquema
    )

    if (response && response.result) {
      girosEncontrados.value = response.result
    }
  } catch (error) {
    console.error('Error al buscar giros:', error)
    girosEncontrados.value = []
  }
}

const seleccionarGiro = (giro) => {
  form.value.id_giro = giro.id_giro
  giroSeleccionado.value = `[${giro.id_giro}] ${giro.descripcion}`
  closeGiroModal()
}

// Funciones de búsqueda de calles
const openCalleModal = () => {
  showCalleModal.value = true
  calleSearch.value = ''
  callesEncontradas.value = []
}

const closeCalleModal = () => {
  showCalleModal.value = false
}

const buscarCalles = async () => {
  if (calleSearch.value.length < 3) {
    callesEncontradas.value = []
    return
  }

  try {
    const response = await execute(
      'sp_get_calles_search',
      'padron_licencias',
      [
        { nombre: 'p_busqueda', valor: calleSearch.value, tipo: 'string' },
        { nombre: 'p_limit', valor: 50, tipo: 'integer' }
      ],
      '',      // tenant
      null,    // pagination
      'comun'  // esquema
    )

    if (response && response.result) {
      callesEncontradas.value = response.result
    }
  } catch (error) {
    console.error('Error al buscar calles:', error)
    callesEncontradas.value = []
  }
}

const seleccionarCalle = (calle) => {
  form.value.cvecalle = calle.cvecalle
  form.value.ubicacion = calle.calle
  form.value.zona = calle.zona
  form.value.subzona = calle.subzona
  closeCalleModal()
  showToast('success', 'Calle seleccionada. Zona y subzona actualizadas automáticamente.')
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

// Utilidades
const getBadgeEstatus = (estatus) => {
  const badges = {
    'T': 'badge-warning',
    'A': 'badge-success',
    'R': 'badge-danger',
    'C': 'badge-secondary'
  }
  return badges[estatus] || 'badge-secondary'
}

const getNombreEstatus = (estatus) => {
  const nombres = {
    'T': 'En Trámite',
    'A': 'Autorizado',
    'R': 'Rechazado',
    'C': 'Cancelado'
  }
  return nombres[estatus] || 'Desconocido'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch {
    return 'N/A'
  }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return 'N/A'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch {
    return 'N/A'
  }
}

// Auto-cargar trámite si viene desde ConsultaTramitefrm
onMounted(() => {
  // Intentar obtener el ID desde sessionStorage (método seguro, ID no visible en URL)
  const idFromSession = sessionStorage.getItem('tramite_a_modificar')

  if (idFromSession) {
    // Limpiar el sessionStorage después de leerlo
    sessionStorage.removeItem('tramite_a_modificar')
    searchId.value = parseInt(idFromSession)
    buscarTramite()
    return
  }

  // Método legacy: verificar si viene ID en la URL (para retrocompatibilidad)
  const idFromRoute = route.params.id
  if (idFromRoute) {
    searchId.value = parseInt(idFromRoute)
    buscarTramite()
  }
})
</script>

<!-- NO inline styles - All styles in municipal-theme.css -->
