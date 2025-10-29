<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Fechas de Descuento</h1>
        <p>Mercados - Fechas de Descuento</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Mantenimiento a Fechas de Descuento</h2>
    <div class="card mb-4">
      <div class="municipal-card-header">Listado de Fechas de Descuento</div>
      <div class="municipal-card-body">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>Mes</th>
              <th>Fecha Descuento</th>
              <th>Fecha Recargos</th>
              <th>Última Modificación</th>
              <th>Usuario</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in fechas" :key="row.mes">
              <td>{{ row.mes }}</td>
              <td>{{ row.fecha_descuento | date }}</td>
              <td>{{ row.fecha_recargos | date }}</td>
              <td>{{ row.fecha_alta | datetime }}</td>
              <td>{{ row.usuario }}</td>
              <td>
                <button class="btn-icon btn-primary" @click="edit(row)">Editar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="showForm" class="municipal-card">
      <div class="municipal-card-header">Editar Fecha de Descuento</div>
      <div class="municipal-card-body">
        <form @submit.prevent="submit">
          <div class="row">
            <div class="col-md-2">
              <label>Mes</label>
              <input type="number" class="municipal-form-control" v-model.number="form.mes" min="1" max="12" disabled />
            </div>
            <div class="col-md-4">
              <label>Fecha Descuento</label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_descuento" required />
            </div>
            <div class="col-md-4">
              <label>Fecha Recargos</label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_recargos" required />
            </div>
          </div>
          <div class="mt-3">
            <button type="submit" class="btn-municipal-success">Guardar</button>
            <button type="button" class="btn-municipal-secondary" @click="cancel">Cancelar</button>
          </div>
          <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
        </form>
      </div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
import axios from 'axios';
export default {
  name: 'FechasDescuentoMnttoPage',
  data() {
    return {
      fechas: [],
      showForm: false,
      form: {
        mes: null,
        fecha_descuento: '',
        fecha_recargos: '',
        id_usuario: null
      },
      error: ''
    };
  },
  filters: {
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    datetime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString();
    }
  },
  created() {
    this.loadFechas();
  },
  methods: {
    loadFechas() {
      axios.post('/api/execute', { action: 'getAll' })
        .then(res => {
          if (res.data.success) {
            this.fechas = res.data.data;
          }
        });
    },
    edit(row) {
      this.form = {
        mes: row.mes,
        fecha_descuento: row.fecha_descuento ? row.fecha_descuento.substr(0, 10) : '',
        fecha_recargos: row.fecha_recargos ? row.fecha_recargos.substr(0, 10) : '',
        id_usuario: this.getCurrentUserId()
      };
      this.error = '';
      this.showForm = true;
    },
    cancel() {
      this.showForm = false;
      this.error = '';
    },
    submit() {
      if (new Date(this.form.fecha_descuento).getMonth() + 1 !== this.form.mes ||
          new Date(this.form.fecha_recargos).getMonth() + 1 !== this.form.mes) {
        this.error = 'La fecha de descuento y recargos debe corresponder al mes seleccionado.';
        return;
      }
      axios.post('/api/execute', {
        action: 'update',
        data: this.form
      }).then(res => {
        if (res.data.success) {
          this.showForm = false;
          this.loadFechas();
        } else {
          this.error = res.data.message || 'Error al guardar.';
        }
      });
    },
    getCurrentUserId() {
      // Debe obtenerse del store o sesión
      return parseInt(localStorage.getItem('user_id') || '1');
    }
  }
};
</script>

<style scoped>
.fechas-descuento-mntto-page {
  max-width: 900px;
  margin: 0 auto;
}
.card { margin-bottom: 1.5rem; }
</style>
