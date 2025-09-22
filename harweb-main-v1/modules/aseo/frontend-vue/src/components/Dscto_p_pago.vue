<template>
  <div class="dscto-pp-page">
    <h1>Descuentos por Pronto Pago</h1>
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Catálogos</span> &gt; <span>Descuentos por Pronto Pago</span>
    </div>
    <div class="form-section">
      <form @submit.prevent="handleCreate">
        <div class="form-row">
          <label for="fecha_inicio">Inicio Periodo</label>
          <input type="date" v-model="form.fecha_inicio" required />
        </div>
        <div class="form-row">
          <label for="fecha_fin">Fin Periodo</label>
          <input type="date" v-model="form.fecha_fin" required />
        </div>
        <div class="form-row">
          <label for="porc_dscto">% Descuento</label>
          <input type="number" v-model="form.porc_dscto" min="0" max="100" step="0.01" required />
        </div>
        <div class="form-row">
          <label for="usuario_mov">Usuario</label>
          <input type="text" v-model="form.usuario_mov" required />
        </div>
        <div class="form-actions">
          <button type="submit">Agregar</button>
          <button type="button" @click="resetForm">Limpiar</button>
        </div>
      </form>
    </div>
    <div class="table-section">
      <h2>Registros</h2>
      <table class="dscto-pp-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Inicio</th>
            <th>Fin</th>
            <th>% Dscto.</th>
            <th>Status</th>
            <th>Fecha At.</th>
            <th>Fecha In.</th>
            <th>Usuario</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.id">
            <td>{{ row.id }}</td>
            <td>{{ formatDate(row.fecha_inicio) }}</td>
            <td>{{ formatDate(row.fecha_fin) }}</td>
            <td>{{ row.porc_dscto }}</td>
            <td>{{ row.status }}</td>
            <td>{{ formatDate(row.fecha_at) }}</td>
            <td>{{ formatDate(row.fecha_in) }}</td>
            <td>{{ row.usuario_mov }}</td>
            <td>
              <button v-if="row.status === 'V'" @click="handleDelete(row)">Cancelar</button>
            </td>
          </tr>
          <tr v-if="rows.length === 0">
            <td colspan="9">No hay registros</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="message" class="message" :class="{'success': success, 'error': !success}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'DsctoPPPage',
  data() {
    return {
      rows: [],
      form: {
        fecha_inicio: '',
        fecha_fin: '',
        porc_dscto: '',
        usuario_mov: ''
      },
      message: '',
      success: true
    };
  },
  mounted() {
    this.fetchRows();
  },
  methods: {
    async fetchRows() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'list', data: {} }
          })
        });
        const json = await res.json();
        this.rows = json.eResponse.data || [];
      } catch (e) {
        this.message = 'Error al cargar registros';
        this.success = false;
      }
    },
    async handleCreate() {
      this.message = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'create',
              data: {
                fecha_inicio: this.form.fecha_inicio,
                fecha_fin: this.form.fecha_fin,
                porc_dscto: this.form.porc_dscto,
                usuario_mov: this.form.usuario_mov
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.message = json.eResponse.message;
          this.success = true;
          this.fetchRows();
          this.resetForm();
        } else {
          this.message = json.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error al agregar registro';
        this.success = false;
      }
    },
    async handleDelete(row) {
      if (!confirm('¿Está seguro de cancelar este descuento?')) return;
      this.message = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'delete',
              data: {
                id: row.id,
                usuario_mov: this.form.usuario_mov || 'admin'
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.message = json.eResponse.message;
          this.success = true;
          this.fetchRows();
        } else {
          this.message = json.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error al cancelar registro';
        this.success = false;
      }
    },
    resetForm() {
      this.form.fecha_inicio = '';
      this.form.fecha_fin = '';
      this.form.porc_dscto = '';
      // this.form.usuario_mov = '';
    },
    formatDate(val) {
      if (!val) return '';
      return val.substr(0, 10);
    }
  }
};
</script>

<style scoped>
.dscto-pp-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.form-section {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 140px;
  font-weight: bold;
}
.form-row input {
  flex: 1;
  padding: 0.4rem;
}
.form-actions {
  display: flex;
  gap: 1rem;
}
.table-section {
  margin-top: 2rem;
}
.dscto-pp-table {
  width: 100%;
  border-collapse: collapse;
}
.dscto-pp-table th, .dscto-pp-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: center;
}
.dscto-pp-table th {
  background: #eee;
}
.message {
  margin-top: 1rem;
  padding: 0.7rem;
  border-radius: 4px;
}
.message.success {
  background: #e0ffe0;
  color: #1a6d1a;
}
.message.error {
  background: #ffe0e0;
  color: #a00;
}
</style>
