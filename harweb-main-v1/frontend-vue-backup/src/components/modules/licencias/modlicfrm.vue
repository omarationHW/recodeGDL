<template>
  <div class="modlicfrm-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Modificar Licencias</li>
      </ol>
    </nav>

    <div class="card mb-4">
      <div class="card-header text-center font-weight-bold">
        MODIFICACIÓN DE DATOS DE LICENCIAS
      </div>
      <div class="card-body">
        <!-- Búsqueda de licencia -->
        <div class="card mb-3">
          <div class="card-header">
            <h6 class="mb-0">Buscar Licencia</h6>
          </div>
          <div class="card-body">
            <form @submit.prevent="buscarLicencia">
              <div class="form-group row align-items-center">
                <label for="busquedaLicencia" class="col-sm-2 col-form-label">Buscar por:</label>
                <div class="col-sm-3">
                  <select v-model="tipoBusqueda" class="form-control" required>
                    <option value="licencia">No. Licencia</option>
                    <option value="propietario">Propietario</option>
                    <option value="actividad">Actividad</option>
                  </select>
                </div>
                <div class="col-sm-4">
                  <input
                    type="text"
                    class="form-control"
                    id="busquedaLicencia"
                    v-model="textoBusqueda"
                    :placeholder="getPlaceholderBusqueda()"
                    required
                  />
                </div>
                <div class="col-sm-3">
                  <button type="submit" class="btn btn-primary mr-2" :disabled="loading">
                    <i class="fa fa-search"></i> Buscar
                  </button>
                  <button type="button" class="btn btn-secondary" @click="limpiarBusqueda">
                    <i class="fa fa-eraser"></i> Limpiar
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>

        <!-- Resultados de búsqueda -->
        <div v-if="resultadosBusqueda.length > 0" class="card mb-3">
          <div class="card-header">
            <h6 class="mb-0">Resultados de búsqueda ({{ resultadosBusqueda.length }} encontrados)</h6>
          </div>
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-bordered table-sm mb-0">
                <thead class="thead-light">
                  <tr>
                    <th>Licencia</th>
                    <th>Propietario</th>
                    <th>Actividad</th>
                    <th>Ubicación</th>
                    <th>Estatus</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="licencia in resultadosBusqueda" :key="licencia.id_licencia">
                    <td>{{ licencia.id_licencia }}</td>
                    <td>{{ licencia.propietario }}</td>
                    <td>{{ licencia.actividad?.substring(0, 40) }}...</td>
                    <td>{{ licencia.domicilio_completo }}</td>
                    <td>
                      <span :class="getEstatusClass(licencia.estatus)">
                        {{ getEstatusText(licencia.estatus) }}
                      </span>
                    </td>
                    <td>
                      <button
                        class="btn btn-sm btn-warning"
                        @click="seleccionarLicencia(licencia)"
                        title="Modificar esta licencia"
                      >
                        <i class="fa fa-edit"></i> Modificar
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Modal de modificación -->
        <div v-if="showModal" class="modal fade show d-block" tabindex="-1" role="dialog" style="background-color: rgba(0,0,0,0.5);">
          <div class="modal-dialog modal-xl" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">
                  <i class="fa fa-edit"></i> Modificar Licencia No. {{ licenciaSeleccionada?.id_licencia }}
                </h5>
                <button type="button" class="close" @click="cancelarModificacion" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div class="modal-body">
                <form @submit.prevent="guardarModificacion">
                  <div class="row">
                    <!-- Datos del propietario -->
                    <div class="col-md-6">
                      <h6 class="text-primary mb-3">
                        <i class="fa fa-user"></i> Datos del Propietario
                      </h6>

                      <div class="form-group">
                        <label for="propietario">Propietario *</label>
                        <input
                          type="text"
                          class="form-control"
                          id="propietario"
                          v-model="formData.propietario"
                          required
                          maxlength="150"
                        />
                      </div>

                      <div class="form-group">
                        <label for="rfc">RFC</label>
                        <input
                          type="text"
                          class="form-control"
                          id="rfc"
                          v-model="formData.rfc"
                          maxlength="13"
                          style="text-transform: uppercase"
                        />
                      </div>

                      <div class="form-group">
                        <label for="domicilio_prop">Domicilio del Propietario</label>
                        <input
                          type="text"
                          class="form-control"
                          id="domicilio_prop"
                          v-model="formData.domicilio_prop"
                          maxlength="200"
                        />
                      </div>

                      <div class="form-group">
                        <label for="telefono_prop">Teléfono</label>
                        <input
                          type="text"
                          class="form-control"
                          id="telefono_prop"
                          v-model="formData.telefono_prop"
                          maxlength="20"
                        />
                      </div>

                      <div class="form-group">
                        <label for="email">Email</label>
                        <input
                          type="email"
                          class="form-control"
                          id="email"
                          v-model="formData.email"
                          maxlength="100"
                        />
                      </div>
                    </div>

                    <!-- Datos del establecimiento -->
                    <div class="col-md-6">
                      <h6 class="text-primary mb-3">
                        <i class="fa fa-building"></i> Datos del Establecimiento
                      </h6>

                      <div class="form-group">
                        <label for="actividad">Actividad *</label>
                        <textarea
                          class="form-control"
                          id="actividad"
                          v-model="formData.actividad"
                          required
                          rows="3"
                          maxlength="500"
                        ></textarea>
                      </div>

                      <div class="form-group">
                        <label for="giro">Giro</label>
                        <select v-model="formData.id_giro" class="form-control">
                          <option value="">Seleccione un giro...</option>
                          <option v-for="giro in girosList" :key="giro.id_giro" :value="giro.id_giro">
                            {{ giro.descripcion_giro }}
                          </option>
                        </select>
                      </div>

                      <div class="form-group">
                        <label for="ubicacion">Ubicación *</label>
                        <input
                          type="text"
                          class="form-control"
                          id="ubicacion"
                          v-model="formData.ubicacion"
                          required
                          maxlength="150"
                        />
                      </div>

                      <div class="row">
                        <div class="col-md-6">
                          <div class="form-group">
                            <label for="numext_ubic">No. Exterior</label>
                            <input
                              type="number"
                              class="form-control"
                              id="numext_ubic"
                              v-model="formData.numext_ubic"
                            />
                          </div>
                        </div>
                        <div class="col-md-6">
                          <div class="form-group">
                            <label for="numint_ubic">No. Interior</label>
                            <input
                              type="text"
                              class="form-control"
                              id="numint_ubic"
                              v-model="formData.numint_ubic"
                              maxlength="10"
                            />
                          </div>
                        </div>
                      </div>

                      <div class="form-group">
                        <label for="colonia_ubic">Colonia</label>
                        <input
                          type="text"
                          class="form-control"
                          id="colonia_ubic"
                          v-model="formData.colonia_ubic"
                          maxlength="100"
                        />
                      </div>

                      <div class="form-group">
                        <label for="zona">Zona</label>
                        <select v-model="formData.zona" class="form-control">
                          <option value="">Seleccione una zona...</option>
                          <option v-for="zona in zonasList" :key="zona.zona_id" :value="zona.zona_id">
                            {{ zona.zona_descripcion }}
                          </option>
                        </select>
                      </div>
                    </div>
                  </div>

                  <!-- Datos adicionales -->
                  <div class="row mt-3">
                    <div class="col-md-12">
                      <h6 class="text-primary mb-3">
                        <i class="fa fa-info-circle"></i> Datos Adicionales
                      </h6>
                    </div>

                    <div class="col-md-3">
                      <div class="form-group">
                        <label for="sup_construida">Superficie Construida (m²)</label>
                        <input
                          type="number"
                          step="0.01"
                          class="form-control"
                          id="sup_construida"
                          v-model="formData.sup_construida"
                        />
                      </div>
                    </div>

                    <div class="col-md-3">
                      <div class="form-group">
                        <label for="num_empleados">No. Empleados</label>
                        <input
                          type="number"
                          class="form-control"
                          id="num_empleados"
                          v-model="formData.num_empleados"
                        />
                      </div>
                    </div>

                    <div class="col-md-3">
                      <div class="form-group">
                        <label for="aforo">Aforo</label>
                        <input
                          type="number"
                          class="form-control"
                          id="aforo"
                          v-model="formData.aforo"
                        />
                      </div>
                    </div>

                    <div class="col-md-3">
                      <div class="form-group">
                        <label for="estatus">Estatus</label>
                        <select v-model="formData.estatus" class="form-control" required>
                          <option value="A">Activa</option>
                          <option value="V">Vigente</option>
                          <option value="S">Suspendida</option>
                          <option value="C">Cancelada</option>
                          <option value="P">Pendiente</option>
                        </select>
                      </div>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="observaciones">Observaciones</label>
                    <textarea
                      class="form-control"
                      id="observaciones"
                      v-model="formData.observaciones"
                      rows="3"
                      maxlength="1000"
                      placeholder="Comentarios sobre la modificación..."
                    ></textarea>
                  </div>
                </form>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" @click="cancelarModificacion">
                  <i class="fa fa-times"></i> Cancelar
                </button>
                <button type="button" class="btn btn-success" @click="guardarModificacion" :disabled="loading">
                  <i class="fa fa-save"></i> Guardar Modificaciones
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Mensajes -->
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="message && !error" class="alert alert-success mt-3">{{ message }}</div>
        <div v-if="loading" class="text-center mt-3">
          <i class="fa fa-spinner fa-spin"></i> Cargando...
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModificarLicenciasForm',
  data() {
    return {
      loading: false,
      error: '',
      message: '',
      tipoBusqueda: 'licencia',
      textoBusqueda: '',
      resultadosBusqueda: [],
      licenciaSeleccionada: null,
      showModal: false,
      girosList: [],
      zonasList: [],
      formData: {
        propietario: '',
        rfc: '',
        domicilio_prop: '',
        telefono_prop: '',
        email: '',
        actividad: '',
        id_giro: '',
        ubicacion: '',
        numext_ubic: '',
        numint_ubic: '',
        colonia_ubic: '',
        zona: '',
        sup_construida: '',
        num_empleados: '',
        aforo: '',
        estatus: 'A',
        observaciones: ''
      }
    };
  },
  mounted() {
    this.cargarGiros();
    this.cargarZonas();
  },
  methods: {
    getPlaceholderBusqueda() {
      switch (this.tipoBusqueda) {
        case 'licencia': return 'Ej: 123456';
        case 'propietario': return 'Ej: Juan Pérez';
        case 'actividad': return 'Ej: Abarrotes';
        default: return '';
      }
    },

    async buscarLicencia() {
      this.loading = true;
      this.error = '';
      this.message = '';
      this.resultadosBusqueda = [];

      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'SP_licencias_search',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_numero_licencia', valor: this.tipoBusqueda === 'licencia' ? this.textoBusqueda : null },
              { nombre: 'p_propietario', valor: this.tipoBusqueda === 'propietario' ? this.textoBusqueda : null },
              { nombre: 'p_nombre_comercial', valor: this.tipoBusqueda === 'actividad' ? this.textoBusqueda : null }
            ],
            Tenant: 'public'
          }
        });

        if (response.data && response.data.success) {
          this.resultadosBusqueda = response.data.data || [];
          if (this.resultadosBusqueda.length === 0) {
            this.message = 'No se encontraron licencias con los criterios especificados.';
          }
        } else {
          this.error = response.data?.message || 'Error al buscar licencias.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },

    async cargarGiros() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'SP_BUSCAGIRO_SEARCH',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_termino', valor: '' }
            ],
            Tenant: 'public'
          }
        });

        if (response.data && response.data.success) {
          this.girosList = response.data.data || [];
        }
      } catch (err) {
        console.error('Error al cargar giros:', err);
      }
    },

    async cargarZonas() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'SP_CONSULTAPREDIAL_LIST',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_cuenta_predial', valor: null },
              { nombre: 'p_propietario', valor: null },
              { nombre: 'p_direccion', valor: null },
              { nombre: 'p_colonia', valor: null },
              { nombre: 'p_limite', valor: 1000 },
              { nombre: 'p_offset', valor: 0 }
            ],
            Tenant: 'public'
          }
        });

        if (response.data && response.data.success) {
          this.zonasList = response.data.data || [];
        }
      } catch (err) {
        console.error('Error al cargar zonas:', err);
      }
    },

    seleccionarLicencia(licencia) {
      this.licenciaSeleccionada = licencia;
      this.formData = {
        propietario: licencia.propietario || '',
        rfc: licencia.rfc || '',
        domicilio_prop: licencia.domicilio || '',
        telefono_prop: licencia.telefono_prop || '',
        email: licencia.email || '',
        actividad: licencia.actividad || '',
        id_giro: licencia.id_giro || '',
        ubicacion: licencia.ubicacion || '',
        numext_ubic: licencia.numext_ubic || '',
        numint_ubic: licencia.numint_ubic || '',
        colonia_ubic: licencia.colonia_ubic || '',
        zona: licencia.zona || '',
        sup_construida: licencia.sup_construida || '',
        num_empleados: licencia.num_empleados || '',
        aforo: licencia.aforo || '',
        estatus: licencia.estatus || 'A',
        observaciones: ''
      };
      this.error = '';
      this.message = '';
      this.showModal = true;
    },

    async guardarModificacion() {
      this.loading = true;
      this.error = '';
      this.message = '';

      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'SP_MODLIC_CREATE',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_folio_modificacion', valor: `MOD-${Date.now()}` },
              { nombre: 'p_numero_licencia', valor: this.licenciaSeleccionada.numero_licencia || this.licenciaSeleccionada.id_licencia },
              { nombre: 'p_tipo_modificacion', valor: 'OTROS' },
              { nombre: 'p_descripcion_cambios', valor: 'Modificación general de datos de licencia' },
              { nombre: 'p_datos_actuales', valor: JSON.stringify(this.licenciaSeleccionada) },
              { nombre: 'p_datos_propuestos', valor: JSON.stringify(this.formData) },
              { nombre: 'p_justificacion', valor: this.formData.observaciones || 'Actualización de datos' },
              { nombre: 'p_propietario', valor: this.formData.propietario },
              { nombre: 'p_usuario_registro', valor: 'usuario_vue' }
            ],
            Tenant: 'public'
          }
        });

        if (response.data && response.data.success) {
          this.$swal.fire({
            title: '¡Éxito!',
            text: 'La licencia ha sido modificada correctamente.',
            icon: 'success',
            confirmButtonText: 'Aceptar'
          });
          this.cancelarModificacion();
          this.buscarLicencia(); // Actualizar resultados
        } else {
          this.error = response.data?.message || 'Error al modificar la licencia.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },

    cancelarModificacion() {
      this.licenciaSeleccionada = null;
      this.formData = {
        propietario: '',
        rfc: '',
        domicilio_prop: '',
        telefono_prop: '',
        email: '',
        actividad: '',
        id_giro: '',
        ubicacion: '',
        numext_ubic: '',
        numint_ubic: '',
        colonia_ubic: '',
        zona: '',
        sup_construida: '',
        num_empleados: '',
        aforo: '',
        estatus: 'A',
        observaciones: ''
      };
      this.error = '';
      this.message = '';
    },

    limpiarBusqueda() {
      this.textoBusqueda = '';
      this.resultadosBusqueda = [];
      this.cancelarModificacion();
      this.error = '';
      this.message = '';
    },

    getEstatusClass(estatus) {
      switch (estatus) {
        case 'A': return 'badge badge-success';
        case 'V': return 'badge badge-primary';
        case 'S': return 'badge badge-warning';
        case 'C': return 'badge badge-danger';
        case 'P': return 'badge badge-info';
        default: return 'badge badge-secondary';
      }
    },

    getEstatusText(estatus) {
      switch (estatus) {
        case 'A': return 'Activa';
        case 'V': return 'Vigente';
        case 'S': return 'Suspendida';
        case 'C': return 'Cancelada';
        case 'P': return 'Pendiente';
        default: return estatus;
      }
    }
  }
};
</script>

<style scoped>
.modlicfrm-page {
  max-width: 1400px;
  margin: 0 auto;
}

.card-header {
  background: #f8f9fa;
  font-size: 1.1rem;
}

.form-group label {
  font-weight: 600;
  color: #495057;
}

.text-primary {
  color: #007bff !important;
}

.table th, .table td {
  vertical-align: middle;
}

.btn-lg {
  padding: 0.75rem 2rem;
}

.alert {
  margin-top: 1rem;
}

.badge {
  font-size: 0.8rem;
}
</style>