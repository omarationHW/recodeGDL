<template>
  <div class="container-fluid py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h1 class="h2 mb-0"><i class="fas fa-calendar-alt me-2"></i>Agenda de Visitas</h1>
        <nav aria-label="breadcrumb">
          <ol class="breadcrumb mb-0">
            <li class="breadcrumb-item"><router-link to="/" class="text-decoration-none">Inicio</router-link></li>
            <li class="breadcrumb-item active" aria-current="page">Agenda de Visitas</li>
          </ol>
        </nav>
      </div>
    </div>

    <!-- Filtros de Búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="fas fa-filter me-2"></i>Filtros de Búsqueda</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscarVisitas">
          <div class="row g-3">
            <div class="col-md-3">
              <label for="fechaIni" class="form-label fw-bold">Fecha inicio</label>
              <div class="input-group">
                <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                <input type="date" v-model="filtros.fechaini" id="fechaIni" class="form-control" required />
              </div>
            </div>
            <div class="col-md-3">
              <label for="fechaFin" class="form-label fw-bold">Fecha fin</label>
              <div class="input-group">
                <span class="input-group-text"><i class="fas fa-calendar"></i></span>
                <input type="date" v-model="filtros.fechafin" id="fechaFin" class="form-control" required />
              </div>
            </div>
            <div class="col-md-4">
              <label for="dependencia" class="form-label fw-bold">Dependencia</label>
              <div class="input-group">
                <span class="input-group-text"><i class="fas fa-building"></i></span>
                <select v-model="filtros.id_dependencia" id="dependencia" class="form-select" required>
                  <option value="" disabled>Seleccione...</option>
                  <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">
                    {{ dep.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div class="col-md-2 d-flex align-items-end">
              <button type="submit" class="btn btn-primary w-100" :disabled="loading">
                <i class="fas fa-search me-1"></i>
                <span v-if="loading">Buscando...</span>
                <span v-else>Buscar</span>
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <!-- Resultados -->
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="card-title mb-0">
          <i class="fas fa-table me-2"></i>Agenda de Visitas
          <span v-if="visitas.length > 0" class="badge bg-primary ms-2">{{ visitas.length }}</span>
        </h5>
        <div class="btn-group">
          <button type="button" class="btn btn-success btn-sm" @click="exportarExcel" :disabled="loading || visitas.length === 0">
            <i class="fas fa-file-excel me-1"></i>Excel
          </button>
          <button type="button" class="btn btn-secondary btn-sm" @click="imprimir" :disabled="visitas.length === 0">
            <i class="fas fa-print me-1"></i>Imprimir
          </button>
        </div>
      </div>
      <div class="card-body p-0">
        <!-- Loading -->
        <div v-if="loading" class="d-flex justify-content-center align-items-center py-5">
          <div class="spinner-border text-primary me-3" role="status"></div>
          <span class="text-primary fw-bold">Cargando agenda de visitas...</span>
        </div>

        <!-- Tabla de resultados -->
        <div v-else-if="visitas.length > 0" class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-dark">
              <tr>
                <th><i class="fas fa-calendar me-1"></i>Fecha Visita</th>
                <th><i class="fas fa-clock me-1"></i>Día</th>
                <th><i class="fas fa-sun me-1"></i>Turno</th>
                <th><i class="fas fa-clock me-1"></i>Hora</th>
                <th><i class="fas fa-map me-1"></i>Zona</th>
                <th><i class="fas fa-map-pin me-1"></i>Subzona</th>
                <th><i class="fas fa-file-alt me-1"></i>Folio</th>
                <th><i class="fas fa-calendar-check me-1"></i>Fecha Trámite</th>
                <th><i class="fas fa-user me-1"></i>Propietario</th>
                <th><i class="fas fa-map-marker-alt me-1"></i>Ubicación</th>
                <th><i class="fas fa-briefcase me-1"></i>Actividad</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in visitas" :key="row.id_tramite + '-' + row.fecha">
                <td><span class="badge bg-info">{{ formatFecha(row.fecha) }}</span></td>
                <td class="fw-bold">{{ row.dia_letras }}</td>
                <td>
                  <span class="badge" :class="getTurnoClass(row.turno)">{{ row.turno }}</span>
                </td>
                <td class="fw-bold text-primary">{{ row.hora }}</td>
                <td><span class="badge bg-secondary">{{ row.zona }}</span></td>
                <td><span class="badge bg-secondary">{{ row.subzona }}</span></td>
                <td><span class="badge bg-primary">{{ row.id_tramite }}</span></td>
                <td>{{ formatFecha(row.feccap) }}</td>
                <td class="fw-bold">{{ row.propietarionvo || row.propietario }}</td>
                <td class="text-muted">{{ row.domcompleto }}</td>
                <td class="text-truncate" style="max-width: 200px;" :title="row.actividad">{{ row.actividad }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Estado vacío -->
        <div v-else class="text-center py-5">
          <div class="display-1 mb-3"><i class="fas fa-calendar-times text-muted"></i></div>
          <h4>No hay visitas programadas</h4>
          <p class="text-muted">No se encontraron visitas agendadas para los filtros seleccionados</p>
        </div>
      </div>
    </div>
    <!-- Modal de impresión -->
    <div ref="printArea" style="display:none">
      <h3 class="text-center">Reporte de Visitas Agendadas</h3>
      <p><strong>Dependencia:</strong> {{ dependenciaSeleccionadaDescripcion }}</p>
      <p><strong>Rango de fechas:</strong> {{ filtros.fechaini }} al {{ filtros.fechafin }}</p>
      <table border="1" cellspacing="0" cellpadding="2" style="width:100%;font-size:12px">
        <thead>
          <tr>
            <th>Fecha Visita</th>
            <th>Día</th>
            <th>Turno</th>
            <th>Hora</th>
            <th>Zona</th>
            <th>Subzona</th>
            <th>Folio</th>
            <th>Fecha Trámite</th>
            <th>Propietario</th>
            <th>Ubicación</th>
            <th>Actividad</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in visitas" :key="row.id_tramite + '-' + row.fecha">
            <td>{{ formatFecha(row.fecha) }}</td>
            <td>{{ row.dia_letras }}</td>
            <td>{{ row.turno }}</td>
            <td>{{ row.hora }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.subzona }}</td>
            <td>{{ row.id_tramite }}</td>
            <td>{{ formatFecha(row.feccap) }}</td>
            <td>{{ row.propietarionvo || row.propietario }}</td>
            <td>{{ row.domcompleto }}</td>
            <td>{{ row.actividad }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'AgendaVisitasPage',
  data() {
    const today = new Date().toISOString().substr(0, 10);
    return {
      dependencias: [],
      visitas: [],
      filtros: {
        fechaini: today,
        fechafin: today,
        id_dependencia: ''
      },
      loading: false
    };
  },
  computed: {
    dependenciaSeleccionadaDescripcion() {
      const dep = this.dependencias.find(d => d.id_dependencia == this.filtros.id_dependencia);
      return dep ? dep.descripcion : '';
    }
  },
  mounted() {
    this.cargarDependencias();
  },
  methods: {
    async cargarDependencias() {
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: 'get_dependencias'
        });
        if (data.eResponse.success) {
          this.dependencias = data.eResponse.data;
        }
      } catch (e) {
        alert('Error cargando dependencias');
      }
    },
    async buscarVisitas() {
      this.loading = true;
      this.visitas = [];
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: 'get_agenda_visitas',
          params: {
            id_dependencia: this.filtros.id_dependencia,
            fechaini: this.filtros.fechaini,
            fechafin: this.filtros.fechafin
          }
        });
        if (data.eResponse.success) {
          this.visitas = data.eResponse.data;
        } else {
          alert(data.eResponse.message || 'Error consultando visitas');
        }
      } catch (e) {
        alert('Error consultando visitas');
      } finally {
        this.loading = false;
      }
    },
    exportarExcel() {
      // Exportar a Excel usando Blob y CSV
      if (!this.visitas.length) return;
      const headers = [
        'Fecha Visita', 'Día', 'Turno', 'Hora', 'Zona', 'Subzona', 'Folio', 'Fecha Trámite', 'Propietario', 'Ubicación', 'Actividad'
      ];
      const rows = this.visitas.map(row => [
        this.formatFecha(row.fecha),
        row.dia_letras,
        row.turno,
        row.hora,
        row.zona,
        row.subzona,
        row.id_tramite,
        this.formatFecha(row.feccap),
        row.propietarionvo || row.propietario,
        row.domcompleto,
        row.actividad
      ]);
      let csvContent = '';
      csvContent += headers.join(';') + '\n';
      rows.forEach(r => {
        csvContent += r.map(x => '"' + (x ? ('' + x).replace(/"/g, '""') : '') + '"').join(';') + '\n';
      });
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.setAttribute('download', 'visitas_agendadas.csv');
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },
    imprimir() {
      // Imprimir usando ventana emergente
      const printContents = this.$refs.printArea.innerHTML;
      const win = window.open('', '', 'width=900,height=700');
      win.document.write('<html><head><title>Reporte de Visitas Agendadas</title>');
      win.document.write('<style>table{border-collapse:collapse;}th,td{border:1px solid #333;padding:2px;}h3{text-align:center;}</style>');
      win.document.write('</head><body>' + printContents + '</body></html>');
      win.document.close();
      win.focus();
      setTimeout(() => {
        win.print();
        win.close();
      }, 500);
    },
    formatFecha(fecha) {
      if (!fecha) return '';
      // Espera formato ISO o yyyy-mm-dd
      return fecha.substr(0, 10);
    },
    getTurnoClass(turno) {
      switch(turno?.toLowerCase()) {
        case 'matutino':
        case 'mañana':
          return 'bg-warning text-dark';
        case 'vespertino':
        case 'tarde':
          return 'bg-info';
        case 'nocturno':
        case 'noche':
          return 'bg-dark';
        default:
          return 'bg-secondary';
      }
    }
  }
};
</script>

<style scoped>
/* Estilos mejorados para la agenda de visitas */
.table th {
  font-size: 13px;
  font-weight: 600;
  border-top: none;
  vertical-align: middle;
}

.table td {
  font-size: 13px;
  vertical-align: middle;
}

.text-truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.badge {
  font-size: 0.75em;
}

/* Hover effects mejorados */
.table-hover tbody tr:hover {
  background-color: rgba(0,123,255,.075);
}

/* Estados responsive */
@media (max-width: 768px) {
  .table th, .table td {
    font-size: 11px;
    padding: 0.5rem 0.25rem;
  }

  .btn-group .btn {
    font-size: 12px;
  }
}
</style>
