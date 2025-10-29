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
    <h1>Fechas de Descuento</h1>
    <div class="alert alert-info mb-3">
      Días de Vencimiento para los Descuentos del Año Actual
    </div>
    <div class="mb-3">
      <button class="btn-municipal-primary" :disabled="!selectedRow" @click="openEditModal">Modificar</button>
      <button class="btn btn-secondary float-end" @click="$router.push('/')">Salir</button>
    </div>
    <table class="table table-striped table-hover">
      <thead>
        <tr>
          <th>Mes</th>
          <th>Fecha Descuento</th>
          <th>Fecha Recargos</th>
          <th>Fecha Actual</th>
          <th>Usuario</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in rows" :key="row.mes" :class="{ 'table-active': selectedRow && selectedRow.mes === row.mes }" @click="selectRow(row)">
          <td class="text-center">{{ row.mes }}</td>
          <td class="text-center">{{ formatDate(row.fecha_descuento) }}</td>
          <td class="text-center">{{ formatDate(row.fecha_recargos) }}</td>
          <td class="text-end">{{ formatDateTime(row.fecha_alta) }}</td>
          <td class="text-center">{{ row.usuario }}</td>
        </tr>
      </tbody>
    </table>

    <!-- Edit Modal -->
    <div v-if="showModal" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Modificar Fecha de Descuento</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="save">
              <div class="mb-3">
                <label class="municipal-form-label">Mes</label>
                <input type="number" class="municipal-form-control" v-model.number="editForm.mes" min="1" max="12" readonly />
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Fecha Descuento</label>
                <input type="date" class="municipal-form-control" v-model="editForm.fecha_descuento" required />
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Fecha Recargos</label>
                <input type="date" class="municipal-form-control" v-model="editForm.fecha_recargos" required />
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Usuario</label>
                <input type="text" class="municipal-form-control" :value="userName" readonly />
              </div>
              <div class="modal-footer">
                <button type="submit" class="btn-municipal-success">Guardar</button>
                <button type="button" class="btn-municipal-secondary" @click="closeModal">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="loading-overlay"><span>Cargando...</span></div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FechaDescuentoPage',
  data() {
    return {
      rows: [],
      selectedRow: null,
      showModal: false,
      editForm: {
        mes: null,
        fecha_descuento: '',
        fecha_recargos: ''
      },
      loading: false,
      error: '',
      userId: 0,
      userName: ''
    };
  },
  created() {
    // Simulación: obtener usuario actual (en producción, usar auth)
    this.userId = window?.AppUser?.id_usuario || 1;
    this.userName = window?.AppUser?.usuario || 'admin';
    this.fetchRows();
  },
  methods: {
    async fetchRows() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'list',
              entity: 'fechadescuento'
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.rows = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al cargar datos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    selectRow(row) {
      this.selectedRow = row;
    },
    openEditModal() {
      if (!this.selectedRow) return;
      this.editForm = {
        mes: this.selectedRow.mes,
        fecha_descuento: this.selectedRow.fecha_descuento ? this.selectedRow.fecha_descuento.substr(0, 10) : '',
        fecha_recargos: this.selectedRow.fecha_recargos ? this.selectedRow.fecha_recargos.substr(0, 10) : ''
      };
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
      this.error = '';
    },
    async save() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'update',
              entity: 'fechadescuento',
              params: {
                mes: this.editForm.mes,
                fecha_descuento: this.editForm.fecha_descuento,
                fecha_recargos: this.editForm.fecha_recargos,
                id_usuario: this.userId
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.showModal = false;
          this.fetchRows();
        } else {
          this.error = data.eResponse.message || 'Error al guardar';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      return new Date(dateStr).toLocaleDateString();
    },
    formatDateTime(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString() + ' ' + d.toLocaleTimeString();
    }
  }
};
</script>

<style scoped>
.fecha-descuento-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table-active {
  background-color: #e9ecef;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}
.modal-dialog {
  background: #fff;
  border-radius: 8px;
  max-width: 400px;
  width: 100%;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
.loading-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(255,255,255,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  z-index: 2000;
}
</style>
