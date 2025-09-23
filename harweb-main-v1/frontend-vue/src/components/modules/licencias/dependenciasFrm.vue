<template>
  <div class="dependencias-page">
    <h1>Gestión de Revisiones/Inspecciones de Trámite</h1>
    <div class="breadcrumb">
      <router-link to="/tramites">Trámites</router-link> /
      <span>Revisiones</span>
    </div>
    <div class="tramite-info" v-if="tramite">
      <h2>Trámite #{{ tramite.id_tramite }}</h2>
      <p><strong>Propietario:</strong> {{ tramite.propietario }}</p>
      <p><strong>Ubicación:</strong> {{ tramite.ubicacion }}</p>
      <p><strong>Estatus:</strong> {{ tramite.estatus }}</p>
    </div>
    <div class="actions">
      <label for="dependencia">Agregar revisión/inspección:</label>
      <select v-model="selectedDependencia" id="dependencia">
        <option value="">Seleccione dependencia</option>
        <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">
          {{ dep.descripcion }}
        </option>
      </select>
      <button @click="addInspeccion" :disabled="!selectedDependencia">Agregar</button>
    </div>
    <h3>Inspecciones actuales</h3>
    <table class="inspecciones-table">
      <thead>
        <tr>
          <th>Dependencia</th>
          <th>Acción</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="insp in inspecciones" :key="insp.id_revision">
          <td>{{ insp.descripcion }}</td>
          <td>
            <button @click="deleteInspeccion(insp.id_dependencia)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="inspecciones.length === 0">
          <td colspan="2">No hay inspecciones asignadas.</td>
        </tr>
      </tbody>
    </table>
    <div class="footer">
      <router-link class="btn" to="/tramites">Regresar</router-link>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'DependenciasPage',
  props: {
    idTramite: {
      type: [String, Number],
      required: true
    }
  },
  data() {
    return {
      dependencias: [],
      inspecciones: [],
      tramite: null,
      selectedDependencia: '',
      error: '',
      success: ''
    };
  },
  mounted() {
    this.loadData();
  },
  methods: {
    async loadData() {
      this.error = '';
      try {
        // Cargar catálogo dependencias
        let depRes = await this.api('get_dependencias', {});
        if (depRes.success) {
          this.dependencias = depRes.data;
        }
        // Cargar inspecciones actuales
        let inspRes = await this.api('get_tramite_inspecciones', { id_tramite: this.idTramite });
        if (inspRes.success) {
          this.inspecciones = inspRes.data;
        }
        // Cargar info trámite
        let tramRes = await this.api('get_tramite_info', { id_tramite: this.idTramite });
        if (tramRes.success) {
          this.tramite = tramRes.data;
        }
      } catch (e) {
        this.error = 'Error al cargar datos: ' + (e.message || e);
      }
    },
    async addInspeccion() {
      this.error = '';
      this.success = '';
      if (!this.selectedDependencia) return;
      try {
        let res = await this.api('add_inspeccion', {
          id_tramite: this.idTramite,
          id_dependencia: this.selectedDependencia
        });
        if (res.success) {
          this.success = 'Inspección agregada correctamente';
          this.selectedDependencia = '';
          await this.loadData();
        } else {
          this.error = res.message || 'No se pudo agregar la inspección';
        }
      } catch (e) {
        this.error = 'Error: ' + (e.message || e);
      }
    },
    async deleteInspeccion(id_dependencia) {
      this.error = '';
      this.success = '';
      if (!confirm('¿Está seguro de eliminar esta inspección?')) return;
      try {
        let res = await this.api('delete_inspeccion', {
          id_tramite: this.idTramite,
          id_dependencia
        });
        if (res.success) {
          this.success = 'Inspección eliminada correctamente';
          await this.loadData();
        } else {
          this.error = res.message || 'No se pudo eliminar la inspección';
        }
      } catch (e) {
        this.error = 'Error: ' + (e.message || e);
      }
    },
    async api(action, params) {
      const response = await fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ action, params })
      });
      return await response.json();
    }
  }
};
</script>

<style scoped>
.dependencias-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.breadcrumb {
  margin-bottom: 1em;
  font-size: 0.95em;
}
.tramite-info {
  background: #f8f8f8;
  padding: 1em;
  border-radius: 4px;
  margin-bottom: 1em;
}
.actions {
  margin-bottom: 1em;
}
.inspecciones-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1em;
}
.inspecciones-table th, .inspecciones-table td {
  border: 1px solid #ddd;
  padding: 0.5em 1em;
}
.footer {
  margin-top: 2em;
}
.error {
  color: #b00;
  margin-top: 1em;
}
.success {
  color: #080;
  margin-top: 1em;
}
</style>
