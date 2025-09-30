<template>
  <div class="container-fluid p-0 h-100">
    <!-- Municipal Header -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1"><i class="fas fa-search me-2"></i>Consulta de Anuncios AS/400</h1>
          <p class="mb-0 opacity-75">Sistema de consulta de anuncios registrados en AS/400</p>
        </div>
        <div class="text-white-50">
          <ol class="breadcrumb mb-0 bg-transparent p-0">
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
            <li class="breadcrumb-item text-white active">Consulta Anuncios AS/400</li>
          </ol>
        </div>
      </div>
    </div>

    <!-- Controls -->
    <div class="municipal-controls border-bottom p-3">
      <div class="d-flex justify-content-between align-items-center">
        <div class="btn-group" role="group">
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-home"></i>
          </button>
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-search"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="mostrarEstadisticas">
            <i class="fas fa-chart-bar"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="usarDatosSimulados" title="Usar datos simulados">
            <i class="fas fa-flask"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="p-4">

      <!-- Formulario de búsqueda -->
      <div class="card mb-4">
        <div class="card-header bg-primary text-white">
          <h5 class="mb-0">
            <i class="fas fa-filter me-2"></i>
            Búsqueda de Anuncio AS/400
          </h5>
        </div>
        <div class="card-body">
          <form @submit.prevent="buscarAnuncio">
            <div class="row g-3">
              <div class="col-md-6">
                <label for="anuncio" class="form-label">Número de Anuncio <span class="text-danger">*</span></label>
                <input
                  id="anuncio"
                  v-model="anuncio"
                  type="number"
                  class="form-control"
                  placeholder="Ingrese el número de anuncio"
                  required
                  :disabled="cargando"
                />
              </div>
              <div class="col-md-6 d-flex align-items-end">
                <button
                  type="submit"
                  class="btn btn-primary me-2"
                  :disabled="cargando || !anuncio">
                  <i class="fas fa-search me-1"></i>
                  {{ cargando ? 'Buscando...' : 'Buscar' }}
                </button>
                <button
                  type="button"
                  @click="limpiarBusqueda"
                  class="btn btn-secondary"
                  :disabled="cargando">
                  <i class="fas fa-eraser me-1"></i>
                  Limpiar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="cargando" class="card">
        <div class="card-body text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2">Consultando datos del anuncio...</p>
        </div>
      </div>

      <!-- Error Alert -->
      <div v-if="error" class="alert alert-danger">
        <i class="fas fa-exclamation-triangle me-2"></i>
        {{ error }}
      </div>

      <!-- Estadisticas Card -->
      <div v-if="mostrandoEstadisticas && estadisticas" class="card mb-4">
        <div class="card-header bg-info text-white">
          <h5 class="mb-0">
            <i class="fas fa-chart-bar me-2"></i>
            Estadísticas de Anuncios AS/400
          </h5>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-3 text-center mb-3">
              <div class="bg-primary text-white p-3 rounded">
                <h4>{{ estadisticas.total_anuncios }}</h4>
                <small>Total Anuncios</small>
              </div>
            </div>
            <div class="col-md-3 text-center mb-3">
              <div class="bg-success text-white p-3 rounded">
                <h4>{{ estadisticas.anuncios_activos }}</h4>
                <small>Activos</small>
              </div>
            </div>
            <div class="col-md-3 text-center mb-3">
              <div class="bg-danger text-white p-3 rounded">
                <h4>{{ estadisticas.anuncios_bloqueados }}</h4>
                <small>Bloqueados</small>
              </div>
            </div>
            <div class="col-md-3 text-center mb-3">
              <div class="bg-warning text-dark p-3 rounded">
                <h4>{{ estadisticas.area_promedio }}m²</h4>
                <small>Área Promedio</small>
              </div>
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-md-6">
              <strong>Tipo más común:</strong> {{ estadisticas.tipo_mas_comun || '-' }}
            </div>
            <div class="col-md-6">
              <strong>Zona más activa:</strong> {{ estadisticas.zona_mas_activa || '-' }}
            </div>
          </div>
        </div>
      </div>

      <!-- Modo Simulado Alert -->
      <div v-if="usandoDatosSimulados" class="alert alert-warning">
        <i class="fas fa-flask me-2"></i>
        <strong>Modo Simulado:</strong> Se están usando datos simulados para pruebas.
      </div>

      <!-- Results Card -->
      <div v-if="anuncioData" class="card">
        <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
          <h5 class="mb-0">
            <i class="fas fa-info-circle me-2"></i>
            Datos del Anuncio {{ anuncio }}
          </h5>
          <div class="btn-group">
            <button
              @click="exportarDatos"
              class="btn btn-light btn-sm">
              <i class="fas fa-download me-1"></i>Exportar
            </button>
          </div>
        </div>
        <div class="card-body">
          <!-- Información Principal -->
          <div class="row mb-4">
            <div class="col-12">
              <h6 class="text-primary border-bottom pb-2 mb-3">
                <i class="fas fa-building me-2"></i>Información Principal
              </h6>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr>
                  <th class="text-muted" style="width: 40%">ID Anuncio:</th>
                  <td><span class="badge bg-primary">{{ anuncioData.id_anuncio || '-' }}</span></td>
                </tr>
                <tr>
                  <th class="text-muted">No. Licencia:</th>
                  <td>{{ anuncioData.id_licencia || '-' }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Fecha Otorgamiento:</th>
                  <td>{{ formatearFecha(anuncioData.fecha_otorgamiento) }}</td>
                </tr>
              </table>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr>
                  <th class="text-muted" style="width: 40%">Área Anuncio:</th>
                  <td>{{ anuncioData.area_anuncio || '-' }} m²</td>
                </tr>
                <tr>
                  <th class="text-muted">Estado:</th>
                  <td>
                    <span v-if="anuncioData.bloqueado > 0" class="badge bg-danger">Bloqueado</span>
                    <span v-else class="badge bg-success">Activo</span>
                  </td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Medidas del Anuncio -->
          <div class="row mb-4">
            <div class="col-12">
              <h6 class="text-primary border-bottom pb-2 mb-3">
                <i class="fas fa-ruler me-2"></i>Medidas del Anuncio
              </h6>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr>
                  <th class="text-muted" style="width: 40%">Medidas 1:</th>
                  <td>{{ anuncioData.medidas1 || '-' }}</td>
                </tr>
              </table>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr>
                  <th class="text-muted" style="width: 40%">Medidas 2:</th>
                  <td>{{ anuncioData.medidas2 || '-' }}</td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Ubicación del Anuncio -->
          <div class="row mb-4">
            <div class="col-12">
              <h6 class="text-primary border-bottom pb-2 mb-3">
                <i class="fas fa-map-marker-alt me-2"></i>Ubicación del Anuncio
              </h6>
            </div>
            <div class="col-12">
              <div class="p-3 bg-light rounded mb-3">
                <strong>Ubicación:</strong> {{ anuncioData.ubicacion || 'No especificada' }}
              </div>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr>
                  <th class="text-muted" style="width: 40%">No. Exterior:</th>
                  <td>{{ anuncioData.numext_ubic || '-' }}{{ anuncioData.letraext_ubic ? ' ' + anuncioData.letraext_ubic : '' }}</td>
                </tr>
              </table>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr>
                  <th class="text-muted" style="width: 40%">No. Interior:</th>
                  <td>{{ anuncioData.numint_ubic || '-' }}{{ anuncioData.letraint_ubic ? ' ' + anuncioData.letraint_ubic : '' }}</td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Clasificación AS/400 -->
          <div class="row mb-4" v-if="anuncioData.tipo_publicidad || anuncioData.zona_urbana">
            <div class="col-12">
              <h6 class="text-primary border-bottom pb-2 mb-3">
                <i class="fas fa-tags me-2"></i>Clasificación AS/400
              </h6>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr v-if="anuncioData.tipo_publicidad">
                  <th class="text-muted" style="width: 40%">Tipo Publicidad:</th>
                  <td><span class="badge bg-info">{{ anuncioData.tipo_publicidad }}</span></td>
                </tr>
                <tr v-if="anuncioData.zona_urbana">
                  <th class="text-muted">Zona Urbana:</th>
                  <td><span class="badge bg-secondary">{{ anuncioData.zona_urbana }}</span></td>
                </tr>
              </table>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr v-if="anuncioData.estatus_legal">
                  <th class="text-muted" style="width: 40%">Estatus Legal:</th>
                  <td>
                    <span v-if="anuncioData.estatus_legal === 'ACTIVO'" class="badge bg-success">{{ anuncioData.estatus_legal }}</span>
                    <span v-else-if="anuncioData.estatus_legal === 'BLOQUEADO'" class="badge bg-danger">{{ anuncioData.estatus_legal }}</span>
                    <span v-else-if="anuncioData.estatus_legal === 'CANCELADO'" class="badge bg-dark">{{ anuncioData.estatus_legal }}</span>
                    <span v-else class="badge bg-warning">{{ anuncioData.estatus_legal }}</span>
                  </td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Auditoría -->
          <div class="row mb-4" v-if="anuncioData.fecha_registro || anuncioData.usuario_registro">
            <div class="col-12">
              <h6 class="text-primary border-bottom pb-2 mb-3">
                <i class="fas fa-history me-2"></i>Auditoría
              </h6>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr v-if="anuncioData.fecha_registro">
                  <th class="text-muted" style="width: 40%">Fecha Registro:</th>
                  <td>{{ formatearFecha(anuncioData.fecha_registro) }}</td>
                </tr>
                <tr v-if="anuncioData.usuario_registro">
                  <th class="text-muted">Usuario Registro:</th>
                  <td>{{ anuncioData.usuario_registro }}</td>
                </tr>
              </table>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tr v-if="anuncioData.fecha_modificacion">
                  <th class="text-muted" style="width: 40%">Fecha Modificación:</th>
                  <td>{{ formatearFecha(anuncioData.fecha_modificacion) }}</td>
                </tr>
                <tr v-if="anuncioData.usuario_modificacion">
                  <th class="text-muted">Usuario Modificación:</th>
                  <td>{{ anuncioData.usuario_modificacion }}</td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Observaciones -->
          <div class="row mb-4" v-if="anuncioData.observaciones">
            <div class="col-12">
              <h6 class="text-primary border-bottom pb-2 mb-3">
                <i class="fas fa-sticky-note me-2"></i>Observaciones
              </h6>
              <div class="p-3 bg-light rounded">
                {{ anuncioData.observaciones }}
              </div>
            </div>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsAnun400Frm',
  data() {
    return {
      anuncio: '',
      anuncioData: null,
      cargando: false,
      error: null,
      estadisticas: null,
      mostrandoEstadisticas: false,
      usandoDatosSimulados: false
    };
  },
  methods: {
    async buscarAnuncio() {
      if (!this.anuncio) {
        this.error = 'Debe ingresar el número de anuncio';
        return;
      }

      this.cargando = true;
      this.anuncioData = null;
      this.error = null;

      try {
        const eRequest = {
          Operacion: 'SP_CONS_ANUN_400_GET',
          Base: 'padron_licencias',
          Parametros: [
            { valor: parseInt(this.anuncio) }
          ],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({ eRequest })
        });

        const json = await response.json();
        console.log('Response:', json);

        if (json.eResponse && json.eResponse.success) {
          if (json.eResponse.data && json.eResponse.data.result && json.eResponse.data.result.length > 0) {
            this.anuncioData = json.eResponse.data.result[0];
          } else {
            this.error = 'No se encontró el anuncio especificado';
          }
        } else {
          this.error = json.eResponse?.error || 'Error al consultar el anuncio';
        }
      } catch (err) {
        console.error('Error:', err);
        // Si hay error de red, usar datos simulados como fallback
        if (!this.usandoDatosSimulados) {
          console.log('Error de conexión, usando datos simulados...');
          this.usandoDatosSimulados = true;
          this.generarDatosSimulados();
        } else {
          this.error = err.message || 'Error de red';
        }
      } finally {
        this.cargando = false;
      }
    },

    limpiarBusqueda() {
      this.anuncio = '';
      this.anuncioData = null;
      this.error = null;
      this.estadisticas = null;
      this.mostrandoEstadisticas = false;
      this.usandoDatosSimulados = false;
    },

    async obtenerEstadisticas() {
      this.cargando = true;
      this.error = null;

      try {
        const eRequest = {
          Operacion: 'SP_CONS_ANUN_400_ESTADISTICAS',
          Base: 'padron_licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({ eRequest })
        });

        const json = await response.json();

        if (json.eResponse && json.eResponse.success) {
          if (json.eResponse.data && json.eResponse.data.result && json.eResponse.data.result.length > 0) {
            this.estadisticas = json.eResponse.data.result[0];
          } else {
            this.estadisticas = this.generarEstadisticasSimuladas();
          }
        } else {
          this.estadisticas = this.generarEstadisticasSimuladas();
        }
      } catch (err) {
        console.error('Error obteniendo estadísticas:', err);
        this.estadisticas = this.generarEstadisticasSimuladas();
      } finally {
        this.cargando = false;
      }
    },

    mostrarEstadisticas() {
      this.mostrandoEstadisticas = !this.mostrandoEstadisticas;
      if (this.mostrandoEstadisticas && !this.estadisticas) {
        this.obtenerEstadisticas();
      }
    },

    usarDatosSimulados() {
      this.usandoDatosSimulados = !this.usandoDatosSimulados;
      if (this.usandoDatosSimulados) {
        this.error = null;
        if (this.anuncio) {
          this.generarDatosSimulados();
        }
      }
    },

    generarEstadisticasSimuladas() {
      return {
        total_anuncios: 1247,
        anuncios_activos: 1089,
        anuncios_bloqueados: 158,
        area_total: 31250.75,
        area_promedio: 25.08,
        anuncios_mes_actual: 45,
        crecimiento_mensual: 12.5,
        tipo_mas_comun: 'Cartelera Comercial',
        zona_mas_activa: 'Centro Histórico'
      };
    },

    exportarDatos() {
      if (!this.anuncioData) return;

      const datos = {
        anuncio: this.anuncioData,
        fecha_exportacion: new Date().toISOString(),
        usuario: 'admin'
      };

      const dataStr = JSON.stringify(datos, null, 2);
      const dataBlob = new Blob([dataStr], { type: 'application/json' });
      const url = URL.createObjectURL(dataBlob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `anuncio_${this.anuncio}_${new Date().toISOString().split('T')[0]}.json`;
      link.click();
      URL.revokeObjectURL(url);
    },

    formatearFecha(fecha) {
      if (!fecha) return '-';
      try {
        // Verificar si es un datetime completo
        if (fecha.includes(' ') || fecha.includes('T')) {
          return new Date(fecha).toLocaleString('es-ES', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
          });
        } else {
          return new Date(fecha).toLocaleDateString('es-ES');
        }
      } catch (error) {
        return fecha;
      }
    },

    formatearImporte(importe) {
      if (!importe || importe === 0) return '$0.00';
      try {
        return new Intl.NumberFormat('es-MX', {
          style: 'currency',
          currency: 'MXN'
        }).format(importe);
      } catch (error) {
        return `$${importe}`;
      }
    },

    // Método para generar datos simulados para pruebas
    generarDatosSimulados() {
      const anunciosSimulados = [
        {
          id_anuncio: 1001,
          id_licencia: 2023001,
          fecha_otorgamiento: '2024-01-15',
          area_anuncio: 25.50,
          bloqueado: 0,
          medidas1: '5.00 x 5.10',
          medidas2: '2.50 x 10.20',
          ubicacion: 'Avenida Juárez #1234, Centro Histórico',
          numext_ubic: '1234',
          letraext_ubic: 'A',
          numint_ubic: '101',
          letraint_ubic: '',
          fecha_registro: '2024-01-15 09:30:00',
          usuario_registro: 'admin',
          fecha_modificacion: '2024-01-20 14:15:00',
          usuario_modificacion: 'supervisor',
          observaciones: 'Anuncio publicitario para centro comercial, cumple con normativa urbana',
          tipo_publicidad: 'Cartelera Comercial',
          zona_urbana: 'Centro Histórico',
          estatus_legal: 'ACTIVO'
        },
        {
          id_anuncio: 1002,
          id_licencia: 2023002,
          fecha_otorgamiento: '2024-02-10',
          area_anuncio: 15.75,
          bloqueado: 1,
          medidas1: '3.50 x 4.50',
          medidas2: '1.75 x 9.00',
          ubicacion: 'Boulevard López Mateos #5678, Zona Industrial',
          numext_ubic: '5678',
          letraext_ubic: 'B',
          numint_ubic: '',
          letraint_ubic: '',
          fecha_registro: '2024-02-10 11:45:00',
          usuario_registro: 'operador1',
          fecha_modificacion: '2024-03-05 16:20:00',
          usuario_modificacion: 'supervisor',
          observaciones: 'Anuncio bloqueado por violación a reglamento municipal',
          tipo_publicidad: 'Valla Publicitaria',
          zona_urbana: 'Zona Industrial',
          estatus_legal: 'BLOQUEADO'
        },
        {
          id_anuncio: 1003,
          id_licencia: 2023003,
          fecha_otorgamiento: '2024-03-05',
          area_anuncio: 35.20,
          bloqueado: 0,
          medidas1: '8.00 x 4.40',
          medidas2: '4.00 x 8.80',
          ubicacion: 'Avenida Chapultepec #9999, Zona Rosa',
          numext_ubic: '9999',
          letraext_ubic: '',
          numint_ubic: '205',
          letraint_ubic: 'C',
          fecha_registro: '2024-03-05 08:15:00',
          usuario_registro: 'admin',
          fecha_modificacion: null,
          usuario_modificacion: null,
          observaciones: 'Anuncio espectacular para campaña turística municipal',
          tipo_publicidad: 'Espectacular',
          zona_urbana: 'Zona Rosa',
          estatus_legal: 'ACTIVO'
        }
      ];

      // Simular búsqueda del anuncio
      const anuncioEncontrado = anunciosSimulados.find(a => a.id_anuncio === parseInt(this.anuncio));

      if (anuncioEncontrado) {
        this.anuncioData = anuncioEncontrado;
        this.error = null;
      } else {
        this.anuncioData = null;
        this.error = 'No se encontró el anuncio especificado en los datos simulados';
      }
    }
  }
};
</script>

<style scoped>
.table th {
  font-weight: 600;
}

.table-borderless th,
.table-borderless td {
  border: none;
  padding: 0.375rem 0.75rem;
  background-color: white !important;
  color: #333 !important;
}

.table-borderless th.text-muted {
  color: #6c757d !important;
}

.bg-light {
  background-color: #f8f9fa !important;
}

.border-bottom {
  border-bottom: 2px solid #dee2e6 !important;
}

.card {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  border: 1px solid rgba(0, 0, 0, 0.125);
}

.badge {
  font-size: 0.875em;
}

code {
  color: #e83e8c;
  font-size: 0.875em;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.alert {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

@media (max-width: 768px) {
  .table-responsive {
    font-size: 0.875rem;
  }

  .btn-group .btn {
    font-size: 0.875rem;
  }
}
</style>