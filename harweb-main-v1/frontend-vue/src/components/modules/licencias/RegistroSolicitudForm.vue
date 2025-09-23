<template>
  <div class="registro-form-container">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/licencias">Licencias</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Formulario Registro Solicitud</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h2 class="mb-0">Formularios de Solicitud</h2>
      <button
        class="btn btn-primary"
        @click="abrirModalCrear"
        :disabled="loading"
      >
        <i class="fas fa-plus"></i> Nuevo Formulario
      </button>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">Filtros de Búsqueda</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscarFormularios">
          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="form-label">Folio Formulario</label>
              <input
                type="text"
                v-model="filtros.folio_formulario"
                class="form-control"
                placeholder="Buscar por folio..."
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Folio Solicitud</label>
              <input
                type="text"
                v-model="filtros.folio_solicitud"
                class="form-control"
                placeholder="Folio de solicitud..."
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Tipo Formulario</label>
              <select v-model="filtros.tipo_formulario" class="form-select">
                <option value="">Todos los tipos</option>
                <option value="INICIAL">Inicial</option>
                <option value="MODIFICACION">Modificación</option>
                <option value="ACTUALIZACION">Actualización</option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Estado</label>
              <select v-model="filtros.estado_formulario" class="form-select">
                <option value="">Todos los estados</option>
                <option value="BORRADOR">Borrador</option>
                <option value="PRESENTADO">Presentado</option>
                <option value="VALIDADO">Validado</option>
                <option value="COMPLETADO">Completado</option>
                <option value="RECHAZADO">Rechazado</option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Validador</label>
              <input
                type="text"
                v-model="filtros.validador_asignado"
                class="form-control"
                placeholder="Nombre del validador..."
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Fecha Desde</label>
              <input
                type="date"
                v-model="filtros.fecha_desde"
                class="form-control"
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Fecha Hasta</label>
              <input
                type="date"
                v-model="filtros.fecha_hasta"
                class="form-control"
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Estado Activo</label>
              <select v-model="filtros.activo" class="form-select">
                <option :value="true">Activos</option>
                <option :value="false">Inactivos</option>
              </select>
            </div>
          </div>
          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary" :disabled="loading">
              <i class="fas fa-search"></i> Buscar
            </button>
            <button type="button" class="btn btn-secondary" @click="limpiarFiltros">
              <i class="fas fa-times"></i> Limpiar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-4">
      <div class="spinner-border" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div v-else class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          Formularios Registrados
          <span class="badge bg-secondary">{{ totalRegistros }}</span>
        </h5>
        <div class="d-flex gap-2">
          <!-- Estadísticas -->
          <button
            class="btn btn-info btn-sm"
            @click="mostrarEstadisticas"
          >
            <i class="fas fa-chart-bar"></i> Estadísticas
          </button>
        </div>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Folio Form.</th>
                <th>Solicitud</th>
                <th>Tipo</th>
                <th>Solicitante</th>
                <th>Estado</th>
                <th>Fecha Present.</th>
                <th>Validador</th>
                <th>Versión</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="formularios.length === 0">
                <td colspan="9" class="text-center py-4 text-muted">
                  No se encontraron formularios con los filtros aplicados
                </td>
              </tr>
              <tr v-for="formulario in formularios" :key="formulario.id">
                <td>
                  <strong>{{ formulario.folio_formulario }}</strong>
                </td>
                <td>
                  <small>{{ formulario.folio_solicitud }}</small>
                </td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(formulario.tipo_formulario)">
                    {{ formatTipoFormulario(formulario.tipo_formulario) }}
                  </span>
                </td>
                <td>
                  <div class="text-truncate" style="max-width: 150px;">
                    {{ formulario.datos_solicitante_nombre || 'Sin nombre' }}
                  </div>
                  <small class="text-muted">
                    {{ formulario.datos_negocio_giro || 'Sin giro' }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(formulario.estado_formulario)">
                    {{ formatEstado(formulario.estado_formulario) }}
                  </span>
                </td>
                <td>
                  {{ formatDateTime(formulario.fecha_presentacion) }}
                </td>
                <td>
                  <small class="text-muted">
                    {{ formulario.validador_asignado || 'Sin asignar' }}
                  </small>
                </td>
                <td>
                  <span class="badge bg-info">v{{ formulario.version_formulario }}</span>
                </td>
                <td>
                  <div class="btn-group" role="group">
                    <button
                      class="btn btn-sm btn-outline-primary"
                      @click="verDetalle(formulario)"
                      title="Ver detalle"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-sm btn-outline-warning"
                      @click="editarFormulario(formulario)"
                      title="Editar"
                      :disabled="formulario.estado_formulario === 'COMPLETADO'"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn btn-sm btn-outline-info"
                      @click="cambiarEstado(formulario)"
                      title="Cambiar estado"
                      :disabled="formulario.estado_formulario === 'COMPLETADO'"
                    >
                      <i class="fas fa-exchange-alt"></i>
                    </button>
                    <button
                      class="btn btn-sm btn-outline-success"
                      @click="presentarFormulario(formulario)"
                      title="Presentar"
                      :disabled="formulario.estado_formulario !== 'BORRADOR'"
                    >
                      <i class="fas fa-paper-plane"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div class="card-footer" v-if="totalRegistros > limite">
        <nav aria-label="Paginación de formularios">
          <ul class="pagination justify-content-center mb-0">
            <li class="page-item" :class="{ disabled: paginaActual === 1 }">
              <button
                class="page-link"
                @click="cambiarPagina(paginaActual - 1)"
                :disabled="paginaActual === 1"
              >
                Anterior
              </button>
            </li>
            <li
              v-for="pagina in paginasVisibles"
              :key="pagina"
              class="page-item"
              :class="{ active: pagina === paginaActual }"
            >
              <button class="page-link" @click="cambiarPagina(pagina)">
                {{ pagina }}
              </button>
            </li>
            <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
              <button
                class="page-link"
                @click="cambiarPagina(paginaActual + 1)"
                :disabled="paginaActual === totalPaginas"
              >
                Siguiente
              </button>
            </li>
          </ul>
        </nav>
        <div class="text-center mt-2">
          <small class="text-muted">
            Mostrando {{ Math.min(limite, totalRegistros) }} de {{ totalRegistros }} registros
            (Página {{ paginaActual }} de {{ totalPaginas }})
          </small>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar Formulario -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalForm"
      :class="{ show: showModalForm }"
      style="display: block;"
    >
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ modoEdicion ? 'Editar' : 'Nuevo' }} Formulario de Solicitud
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalForm"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarFormulario">
              <!-- Información básica -->
              <div class="row mb-4">
                <div class="col-12">
                  <h6 class="border-bottom pb-2">Información Básica</h6>
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Folio Formulario *</label>
                  <input
                    type="text"
                    v-model="formData.folio_formulario"
                    class="form-control"
                    :class="{ 'is-invalid': errors.folio_formulario }"
                    required
                    :readonly="modoEdicion"
                  >
                  <div v-if="errors.folio_formulario" class="invalid-feedback">
                    {{ errors.folio_formulario }}
                  </div>
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Folio Solicitud *</label>
                  <input
                    type="text"
                    v-model="formData.folio_solicitud"
                    class="form-control"
                    :class="{ 'is-invalid': errors.folio_solicitud }"
                    required
                    :readonly="modoEdicion"
                  >
                  <div v-if="errors.folio_solicitud" class="invalid-feedback">
                    {{ errors.folio_solicitud }}
                  </div>
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Tipo Formulario *</label>
                  <select
                    v-model="formData.tipo_formulario"
                    class="form-select"
                    :class="{ 'is-invalid': errors.tipo_formulario }"
                    required
                  >
                    <option value="">Seleccionar tipo</option>
                    <option value="INICIAL">Inicial</option>
                    <option value="MODIFICACION">Modificación</option>
                    <option value="ACTUALIZACION">Actualización</option>
                  </select>
                  <div v-if="errors.tipo_formulario" class="invalid-feedback">
                    {{ errors.tipo_formulario }}
                  </div>
                </div>
              </div>

              <!-- Datos del Solicitante -->
              <div class="row mb-4">
                <div class="col-12">
                  <h6 class="border-bottom pb-2">Datos del Solicitante</h6>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Nombre Completo *</label>
                  <input
                    type="text"
                    v-model="formData.datos_solicitante.nombre_completo"
                    class="form-control"
                    required
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">RFC</label>
                  <input
                    type="text"
                    v-model="formData.datos_solicitante.rfc"
                    class="form-control"
                    maxlength="20"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">CURP</label>
                  <input
                    type="text"
                    v-model="formData.datos_solicitante.curp"
                    class="form-control"
                    maxlength="20"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Teléfono</label>
                  <input
                    type="text"
                    v-model="formData.datos_solicitante.telefono"
                    class="form-control"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Email</label>
                  <input
                    type="email"
                    v-model="formData.datos_solicitante.email"
                    class="form-control"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Nacionalidad</label>
                  <input
                    type="text"
                    v-model="formData.datos_solicitante.nacionalidad"
                    class="form-control"
                  >
                </div>
                <div class="col-md-12 mb-3">
                  <label class="form-label">Domicilio Particular</label>
                  <textarea
                    v-model="formData.datos_solicitante.domicilio"
                    class="form-control"
                    rows="2"
                  ></textarea>
                </div>
              </div>

              <!-- Datos del Negocio -->
              <div class="row mb-4">
                <div class="col-12">
                  <h6 class="border-bottom pb-2">Datos del Negocio</h6>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Nombre Comercial *</label>
                  <input
                    type="text"
                    v-model="formData.datos_negocio.nombre_comercial"
                    class="form-control"
                    required
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Giro *</label>
                  <input
                    type="text"
                    v-model="formData.datos_negocio.giro"
                    class="form-control"
                    required
                  >
                </div>
                <div class="col-md-12 mb-3">
                  <label class="form-label">Dirección del Establecimiento *</label>
                  <textarea
                    v-model="formData.datos_negocio.direccion"
                    class="form-control"
                    rows="2"
                    required
                  ></textarea>
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Superficie (m²)</label>
                  <input
                    type="number"
                    v-model="formData.datos_negocio.superficie"
                    class="form-control"
                    step="0.01"
                    min="0"
                  >
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Número de Empleados</label>
                  <input
                    type="number"
                    v-model="formData.datos_negocio.numero_empleados"
                    class="form-control"
                    min="0"
                  >
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Horario de Operación</label>
                  <input
                    type="text"
                    v-model="formData.datos_negocio.horario"
                    class="form-control"
                    placeholder="Ej: 8:00 - 18:00"
                  >
                </div>
              </div>

              <!-- Datos Técnicos -->
              <div class="row mb-4">
                <div class="col-12">
                  <h6 class="border-bottom pb-2">Datos Técnicos</h6>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Capacidad Instalada</label>
                  <input
                    type="text"
                    v-model="formData.datos_tecnicos.capacidad_instalada"
                    class="form-control"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Maquinaria Principal</label>
                  <input
                    type="text"
                    v-model="formData.datos_tecnicos.maquinaria"
                    class="form-control"
                  >
                </div>
                <div class="col-md-12 mb-3">
                  <label class="form-label">Medidas de Seguridad</label>
                  <textarea
                    v-model="formData.datos_tecnicos.medidas_seguridad"
                    class="form-control"
                    rows="2"
                    placeholder="Describa las medidas de seguridad implementadas..."
                  ></textarea>
                </div>
              </div>

              <!-- Documentos -->
              <div class="row mb-4">
                <div class="col-12">
                  <h6 class="border-bottom pb-2">Documentos Anexos</h6>
                </div>
                <div class="col-md-12">
                  <div class="form-check mb-2" v-for="doc in documentosDisponibles" :key="doc.id">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      :value="doc.id"
                      v-model="formData.documentos_seleccionados"
                      :id="`doc_${doc.id}`"
                    >
                    <label class="form-check-label" :for="`doc_${doc.id}`">
                      {{ doc.nombre }}
                    </label>
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalForm">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="guardarFormulario"
              :disabled="guardando"
            >
              <span v-if="guardando" class="spinner-border spinner-border-sm me-2"></span>
              {{ modoEdicion ? 'Actualizar' : 'Crear' }} Formulario
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalDetalle"
      :class="{ show: showModalDetalle }"
      style="display: block;"
    >
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              Detalle de Formulario: {{ formularioDetalle?.folio_formulario }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalDetalle"></button>
          </div>
          <div class="modal-body" v-if="formularioDetalle">
            <div class="row">
              <div class="col-md-6 mb-2">
                <strong>Tipo:</strong> {{ formatTipoFormulario(formularioDetalle.tipo_formulario) }}
              </div>
              <div class="col-md-6 mb-2">
                <strong>Estado:</strong>
                <span class="badge" :class="getEstadoBadgeClass(formularioDetalle.estado_formulario)">
                  {{ formatEstado(formularioDetalle.estado_formulario) }}
                </span>
              </div>
              <div class="col-md-6 mb-2">
                <strong>Folio Solicitud:</strong> {{ formularioDetalle.folio_solicitud }}
              </div>
              <div class="col-md-6 mb-2">
                <strong>Versión:</strong> {{ formularioDetalle.version_formulario }}
              </div>
            </div>

            <!-- Mostrar datos en formato JSON de manera legible -->
            <div class="mt-3">
              <h6>Datos del Solicitante:</h6>
              <pre class="bg-light p-2 rounded">{{ JSON.stringify(formularioDetalle.datos_solicitante, null, 2) }}</pre>
            </div>

            <div class="mt-3">
              <h6>Datos del Negocio:</h6>
              <pre class="bg-light p-2 rounded">{{ JSON.stringify(formularioDetalle.datos_negocio, null, 2) }}</pre>
            </div>

            <div class="mt-3" v-if="formularioDetalle.datos_tecnicos">
              <h6>Datos Técnicos:</h6>
              <pre class="bg-light p-2 rounded">{{ JSON.stringify(formularioDetalle.datos_tecnicos, null, 2) }}</pre>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalDetalle">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Cambiar Estado -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalEstado"
      :class="{ show: showModalEstado }"
      style="display: block;"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              Cambiar Estado: {{ formularioEstado?.folio_formulario }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalEstado"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="actualizarEstado">
              <div class="mb-3">
                <label class="form-label">Nuevo Estado</label>
                <select v-model="nuevoEstado" class="form-select" required>
                  <option value="">Seleccionar estado</option>
                  <option value="BORRADOR">Borrador</option>
                  <option value="PRESENTADO">Presentado</option>
                  <option value="VALIDADO">Validado</option>
                  <option value="COMPLETADO">Completado</option>
                  <option value="RECHAZADO">Rechazado</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Validador Asignado</label>
                <input
                  type="text"
                  v-model="validadorAsignado"
                  class="form-control"
                  placeholder="Nombre del validador"
                >
              </div>
              <div class="mb-3">
                <label class="form-label">Observaciones de Validación</label>
                <textarea
                  v-model="observacionesValidacion"
                  class="form-control"
                  rows="4"
                  placeholder="Ingrese observaciones..."
                ></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalEstado">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="actualizarEstado"
              :disabled="!nuevoEstado"
            >
              Actualizar Estado
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Estadísticas -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalEstadisticas"
      :class="{ show: showModalEstadisticas }"
      style="display: block;"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Estadísticas de Formularios</h5>
            <button type="button" class="btn-close" @click="cerrarModalEstadisticas"></button>
          </div>
          <div class="modal-body" v-if="estadisticas">
            <div class="row">
              <div class="col-md-4 mb-3">
                <div class="card bg-primary text-white">
                  <div class="card-body text-center">
                    <h3>{{ estadisticas.total_formularios }}</h3>
                    <p class="mb-0">Total Formularios</p>
                  </div>
                </div>
              </div>
              <div class="col-md-4 mb-3">
                <div class="card bg-success text-white">
                  <div class="card-body text-center">
                    <h3>{{ estadisticas.formularios_completados }}</h3>
                    <p class="mb-0">Completados</p>
                  </div>
                </div>
              </div>
              <div class="col-md-4 mb-3">
                <div class="card bg-warning text-white">
                  <div class="card-body text-center">
                    <h3>{{ estadisticas.formularios_pendientes }}</h3>
                    <p class="mb-0">Pendientes</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-info text-white">
                  <div class="card-body text-center">
                    <h4>{{ estadisticas.formularios_borrador }}</h4>
                    <p class="mb-0">Borrador</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-secondary text-white">
                  <div class="card-body text-center">
                    <h4>{{ estadisticas.formularios_presentados }}</h4>
                    <p class="mb-0">Presentados</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-primary">
                  <div class="card-body text-center text-white">
                    <h4>{{ estadisticas.formularios_validados }}</h4>
                    <p class="mb-0">Validados</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-danger text-white">
                  <div class="card-body text-center">
                    <h4>{{ estadisticas.formularios_rechazados }}</h4>
                    <p class="mb-0">Rechazados</p>
                  </div>
                </div>
              </div>
              <div class="col-md-12">
                <div class="card">
                  <div class="card-body text-center">
                    <h4>{{ Math.round(estadisticas.tiempo_promedio_validacion || 0) }} días</h4>
                    <p class="mb-0">Tiempo Promedio de Validación</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalEstadisticas">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Backdrop para modales -->
    <div
      v-if="showModalForm || showModalDetalle || showModalEstado || showModalEstadisticas"
      class="modal-backdrop fade show"
    ></div>

    <!-- Alertas -->
    <div
      v-if="mensaje"
      class="alert alert-dismissible fade show fixed-top mx-3"
      :class="tipoMensaje === 'success' ? 'alert-success' : 'alert-danger'"
      style="top: 20px; z-index: 1060;"
    >
      {{ mensaje }}
      <button type="button" class="btn-close" @click="cerrarMensaje"></button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RegistroSolicitudForm',
  data() {
    return {
      // Estados de UI
      loading: false,
      guardando: false,
      showModalForm: false,
      showModalDetalle: false,
      showModalEstado: false,
      showModalEstadisticas: false,
      modoEdicion: false,

      // Datos principales
      formularios: [],
      totalRegistros: 0,
      estadisticas: null,

      // Paginación
      paginaActual: 1,
      limite: 20,

      // Filtros
      filtros: {
        folio_formulario: '',
        folio_solicitud: '',
        tipo_formulario: '',
        estado_formulario: '',
        validador_asignado: '',
        fecha_desde: '',
        fecha_hasta: '',
        activo: true
      },

      // Formulario
      formData: {
        folio_formulario: '',
        folio_solicitud: '',
        tipo_formulario: '',
        datos_solicitante: {
          nombre_completo: '',
          rfc: '',
          curp: '',
          telefono: '',
          email: '',
          nacionalidad: '',
          domicilio: ''
        },
        datos_negocio: {
          nombre_comercial: '',
          giro: '',
          direccion: '',
          superficie: null,
          numero_empleados: null,
          horario: ''
        },
        datos_tecnicos: {
          capacidad_instalada: '',
          maquinaria: '',
          medidas_seguridad: ''
        },
        documentos_seleccionados: []
      },

      // Estados de modales
      formularioDetalle: null,
      formularioEstado: null,
      nuevoEstado: '',
      validadorAsignado: '',
      observacionesValidacion: '',

      // Catálogos
      documentosDisponibles: [
        { id: 'acta_constitutiva', nombre: 'Acta Constitutiva' },
        { id: 'rfc', nombre: 'RFC' },
        { id: 'identificacion', nombre: 'Identificación Oficial' },
        { id: 'comprobante_domicilio', nombre: 'Comprobante de Domicilio' },
        { id: 'planos', nombre: 'Planos del Establecimiento' },
        { id: 'uso_suelo', nombre: 'Licencia de Uso de Suelo' },
        { id: 'proteccion_civil', nombre: 'Visto Bueno de Protección Civil' },
        { id: 'ecologia', nombre: 'Dictamen de Impacto Ambiental' }
      ],

      // Validación y mensajes
      errors: {},
      mensaje: '',
      tipoMensaje: 'success'
    };
  },

  computed: {
    totalPaginas() {
      return Math.ceil(this.totalRegistros / this.limite);
    },

    paginasVisibles() {
      const paginas = [];
      const inicio = Math.max(1, this.paginaActual - 2);
      const fin = Math.min(this.totalPaginas, inicio + 4);

      for (let i = inicio; i <= fin; i++) {
        paginas.push(i);
      }
      return paginas;
    }
  },

  mounted() {
    this.buscarFormularios();
  },

  methods: {
    // Búsqueda y paginación
    async buscarFormularios() {
      this.loading = true;
      try {
        const offset = (this.paginaActual - 1) * this.limite;
        const response = await this.$axios.post('/api/execute', {
          action: 'informix.SP_REGSOLFORM_LIST',
          payload: {
            ...this.filtros,
            p_limite: this.limite,
            p_offset: offset
          }
        });

        if (response.data.status === 'success') {
          this.formularios = response.data.eResponse.data.result || [];
          this.totalRegistros = this.formularios.length > 0 ? this.formularios[0].total_registros : 0;
        } else {
          this.mostrarMensaje('Error al cargar formularios: ' + response.data.message, 'error');
          this.formularios = [];
          this.totalRegistros = 0;
        }
      } catch (error) {
        console.error('Error:', error);
        this.mostrarMensaje('Error de conexión al cargar formularios', 'error');
        this.formularios = [];
        this.totalRegistros = 0;
      } finally {
        this.loading = false;
      }
    },

    cambiarPagina(pagina) {
      if (pagina >= 1 && pagina <= this.totalPaginas) {
        this.paginaActual = pagina;
        this.buscarFormularios();
      }
    },

    limpiarFiltros() {
      this.filtros = {
        folio_formulario: '',
        folio_solicitud: '',
        tipo_formulario: '',
        estado_formulario: '',
        validador_asignado: '',
        fecha_desde: '',
        fecha_hasta: '',
        activo: true
      };
      this.paginaActual = 1;
      this.buscarFormularios();
    },

    // Modales
    abrirModalCrear() {
      this.modoEdicion = false;
      this.formData = {
        folio_formulario: '',
        folio_solicitud: '',
        tipo_formulario: '',
        datos_solicitante: {
          nombre_completo: '',
          rfc: '',
          curp: '',
          telefono: '',
          email: '',
          nacionalidad: '',
          domicilio: ''
        },
        datos_negocio: {
          nombre_comercial: '',
          giro: '',
          direccion: '',
          superficie: null,
          numero_empleados: null,
          horario: ''
        },
        datos_tecnicos: {
          capacidad_instalada: '',
          maquinaria: '',
          medidas_seguridad: ''
        },
        documentos_seleccionados: []
      };
      this.errors = {};
      this.showModalForm = true;
    },

    async editarFormulario(formulario) {
      this.modoEdicion = true;

      try {
        const response = await this.$axios.post('/api/execute', {
          action: 'informix.SP_REGSOLFORM_DETAIL',
          payload: { p_folio_formulario: formulario.folio_formulario }
        });

        if (response.data.status === 'success' && response.data.eResponse.data.result.length > 0) {
          const detalle = response.data.eResponse.data.result[0];
          this.formData = {
            id: detalle.id,
            folio_formulario: detalle.folio_formulario,
            folio_solicitud: detalle.folio_solicitud,
            tipo_formulario: detalle.tipo_formulario,
            datos_solicitante: detalle.datos_solicitante || {},
            datos_negocio: detalle.datos_negocio || {},
            datos_tecnicos: detalle.datos_tecnicos || {},
            documentos_seleccionados: detalle.documentos_anexos || []
          };
          this.errors = {};
          this.showModalForm = true;
        }
      } catch (error) {
        this.mostrarMensaje('Error al cargar los datos del formulario', 'error');
      }
    },

    cerrarModalForm() {
      this.showModalForm = false;
      this.formData = {};
      this.errors = {};
    },

    async verDetalle(formulario) {
      try {
        const response = await this.$axios.post('/api/execute', {
          action: 'informix.SP_REGSOLFORM_DETAIL',
          payload: { p_folio_formulario: formulario.folio_formulario }
        });

        if (response.data.status === 'success' && response.data.eResponse.data.result.length > 0) {
          this.formularioDetalle = response.data.eResponse.data.result[0];
          this.showModalDetalle = true;
        }
      } catch (error) {
        this.mostrarMensaje('Error al cargar el detalle del formulario', 'error');
      }
    },

    cerrarModalDetalle() {
      this.showModalDetalle = false;
      this.formularioDetalle = null;
    },

    cambiarEstado(formulario) {
      this.formularioEstado = formulario;
      this.nuevoEstado = '';
      this.validadorAsignado = '';
      this.observacionesValidacion = '';
      this.showModalEstado = true;
    },

    cerrarModalEstado() {
      this.showModalEstado = false;
      this.formularioEstado = null;
      this.nuevoEstado = '';
      this.validadorAsignado = '';
      this.observacionesValidacion = '';
    },

    async mostrarEstadisticas() {
      try {
        const response = await this.$axios.post('/api/execute', {
          action: 'informix.SP_REGSOLFORM_ESTADISTICAS',
          payload: {
            p_fecha_desde: this.filtros.fecha_desde || null,
            p_fecha_hasta: this.filtros.fecha_hasta || null
          }
        });

        if (response.data.status === 'success' && response.data.eResponse.data.result.length > 0) {
          this.estadisticas = response.data.eResponse.data.result[0];
          this.showModalEstadisticas = true;
        }
      } catch (error) {
        this.mostrarMensaje('Error al cargar estadísticas', 'error');
      }
    },

    cerrarModalEstadisticas() {
      this.showModalEstadisticas = false;
      this.estadisticas = null;
    },

    // CRUD Operations
    async guardarFormulario() {
      this.errors = {};

      // Validaciones básicas
      if (!this.formData.folio_formulario?.trim()) {
        this.errors.folio_formulario = 'El folio del formulario es requerido';
      }
      if (!this.formData.folio_solicitud?.trim()) {
        this.errors.folio_solicitud = 'El folio de solicitud es requerido';
      }
      if (!this.formData.tipo_formulario) {
        this.errors.tipo_formulario = 'El tipo de formulario es requerido';
      }

      if (Object.keys(this.errors).length > 0) {
        return;
      }

      this.guardando = true;

      try {
        // Preparar datos en formato JSON
        const documentosAnexos = this.formData.documentos_seleccionados.map(docId => {
          const doc = this.documentosDisponibles.find(d => d.id === docId);
          return { id: docId, nombre: doc?.nombre };
        });

        const action = this.modoEdicion ? 'informix.SP_REGSOLFORM_UPDATE' : 'informix.SP_REGSOLFORM_CREATE';
        const payload = this.modoEdicion ? {
          p_id: this.formData.id,
          p_datos_solicitante: JSON.stringify(this.formData.datos_solicitante),
          p_datos_negocio: JSON.stringify(this.formData.datos_negocio),
          p_datos_tecnicos: JSON.stringify(this.formData.datos_tecnicos),
          p_documentos_anexos: JSON.stringify(documentosAnexos)
        } : {
          p_folio_formulario: this.formData.folio_formulario,
          p_folio_solicitud: this.formData.folio_solicitud,
          p_tipo_formulario: this.formData.tipo_formulario,
          p_datos_solicitante: JSON.stringify(this.formData.datos_solicitante),
          p_datos_negocio: JSON.stringify(this.formData.datos_negocio),
          p_datos_tecnicos: JSON.stringify(this.formData.datos_tecnicos),
          p_documentos_anexos: JSON.stringify(documentosAnexos),
          p_usuario_creacion: 'USUARIO_ACTUAL' // TODO: obtener del contexto
        };

        const response = await this.$axios.post('/api/execute', {
          action,
          payload
        });

        if (response.data.status === 'success') {
          const resultado = response.data.eResponse.data.result[0];
          if (resultado.success) {
            this.mostrarMensaje(resultado.message, 'success');
            this.cerrarModalForm();
            this.buscarFormularios();
          } else {
            this.mostrarMensaje(resultado.message, 'error');
          }
        } else {
          this.mostrarMensaje('Error al guardar: ' + response.data.message, 'error');
        }
      } catch (error) {
        console.error('Error:', error);
        this.mostrarMensaje('Error de conexión al guardar el formulario', 'error');
      } finally {
        this.guardando = false;
      }
    },

    async actualizarEstado() {
      if (!this.nuevoEstado) return;

      try {
        const response = await this.$axios.post('/api/execute', {
          action: 'informix.SP_REGSOLFORM_UPDATE_STATUS',
          payload: {
            p_folio_formulario: this.formularioEstado.folio_formulario,
            p_estado_formulario: this.nuevoEstado,
            p_validador_asignado: this.validadorAsignado,
            p_observaciones_validacion: this.observacionesValidacion
          }
        });

        if (response.data.status === 'success') {
          const resultado = response.data.eResponse.data.result[0];
          if (resultado.success) {
            this.mostrarMensaje(resultado.message, 'success');
            this.cerrarModalEstado();
            this.buscarFormularios();
          } else {
            this.mostrarMensaje(resultado.message, 'error');
          }
        }
      } catch (error) {
        this.mostrarMensaje('Error al actualizar el estado', 'error');
      }
    },

    async presentarFormulario(formulario) {
      if (formulario.estado_formulario !== 'BORRADOR') return;

      try {
        const response = await this.$axios.post('/api/execute', {
          action: 'informix.SP_REGSOLFORM_PRESENTAR',
          payload: {
            p_folio_formulario: formulario.folio_formulario
          }
        });

        if (response.data.status === 'success') {
          const resultado = response.data.eResponse.data.result[0];
          if (resultado.success) {
            this.mostrarMensaje(resultado.message, 'success');
            this.buscarFormularios();
          } else {
            this.mostrarMensaje(resultado.message, 'error');
          }
        }
      } catch (error) {
        this.mostrarMensaje('Error al presentar el formulario', 'error');
      }
    },

    // Utilidades de formato
    formatDateTime(datetime) {
      if (!datetime) return '';
      return new Date(datetime).toLocaleString('es-MX');
    },

    formatTipoFormulario(tipo) {
      const tipos = {
        'INICIAL': 'Inicial',
        'MODIFICACION': 'Modificación',
        'ACTUALIZACION': 'Actualización'
      };
      return tipos[tipo] || tipo;
    },

    formatEstado(estado) {
      const estados = {
        'BORRADOR': 'Borrador',
        'PRESENTADO': 'Presentado',
        'VALIDADO': 'Validado',
        'COMPLETADO': 'Completado',
        'RECHAZADO': 'Rechazado'
      };
      return estados[estado] || estado;
    },

    getTipoBadgeClass(tipo) {
      const clases = {
        'INICIAL': 'bg-primary',
        'MODIFICACION': 'bg-warning',
        'ACTUALIZACION': 'bg-info'
      };
      return clases[tipo] || 'bg-secondary';
    },

    getEstadoBadgeClass(estado) {
      const clases = {
        'BORRADOR': 'bg-secondary',
        'PRESENTADO': 'bg-info',
        'VALIDADO': 'bg-warning',
        'COMPLETADO': 'bg-success',
        'RECHAZADO': 'bg-danger'
      };
      return clases[estado] || 'bg-secondary';
    },

    // Mensajes
    mostrarMensaje(texto, tipo = 'success') {
      this.mensaje = texto;
      this.tipoMensaje = tipo;
      setTimeout(() => {
        this.mensaje = '';
      }, 5000);
    },

    cerrarMensaje() {
      this.mensaje = '';
    }
  }
};
</script>

<style scoped>
.registro-form-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.modal {
  display: block;
  background: rgba(0,0,0,0.5);
}

.modal-dialog {
  margin-top: 3vh;
}

.table th {
  background-color: #f8f9fa;
  border-bottom: 2px solid #dee2e6;
  font-weight: 600;
}

.table td {
  vertical-align: middle;
}

.btn-group .btn {
  border-radius: 0.25rem;
  margin-right: 2px;
}

.badge {
  font-size: 0.75em;
}

.form-label {
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.card {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}

.fixed-top {
  position: fixed;
  top: 0;
  right: 0;
  left: 0;
}

pre {
  font-size: 0.875rem;
  max-height: 200px;
  overflow-y: auto;
}

@media (max-width: 768px) {
  .registro-form-container {
    padding: 10px;
  }

  .table-responsive {
    font-size: 0.875rem;
  }

  .btn-group .btn {
    padding: 0.25rem 0.5rem;
  }
}
</style>