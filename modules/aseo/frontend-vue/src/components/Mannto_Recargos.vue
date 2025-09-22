<template>
  <div class="recargos-page">
    <h1>Mantenimiento de Recargos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Recargos</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Buscar Recargos por Año</div>
      <div class="card-body">
        <form @submit.prevent="fetchRecargos">
          <div class="form-row align-items-end">
            <div class="col-auto">
              <label for="year">Año</label>
              <input v-model.number="searchYear" type="number" min="1900" class="form-control" id="year" required />
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
            <div class="col-auto ml-auto">
              <button class="btn btn-success" @click.prevent="showCreate = true">Nuevo Recargo</button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div v-if="recargos.length" class="card mb-3">
      <div class="card-header">Recargos del año {{ searchYear }}</div>
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>Mes</th>
              <th>% Recargo</th>
              <th>% Multa</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in recargos" :key="r.ano_mes">
              <td>{{ r.mes }}</td>
              <td>{{ r.porc_recargo }}</td>
              <td>{{ r.porc_multa }}</td>
              <td>
                <button class="btn btn-sm btn-warning mr-1" @click="editRecargo(r)">Editar</button>
                <button class="btn btn-sm btn-danger" @click="deleteRecargo(r)">Eliminar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Crear/Editar Modal -->
    <div v-if="showCreate || editItem" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editItem ? 'Editar Recargo' : 'Nuevo Recargo' }}</h5>
            <button type="button" class="close" @click="closeModal">&times;</button>
          </div>
          <form @submit.prevent="saveRecargo">
            <div class="modal-body">
              <div class="form-row">
                <div class="col">
                  <label for="modalYear">Año</label>
                  <input v-model.number="form.year" type="number" min="1900" class="form-control" id="modalYear" :readonly="!!editItem" required />
                </div>
                <div class="col">
                  <label for="modalMonth">Mes</label>
                  <select v-model.number="form.month" class="form-control" id="modalMonth" :disabled="!!editItem" required>
                    <option v-for="m in 12" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
                  </select>
                </div>
              </div>
              <div class="form-row mt-2">
                <div class="col">
                  <label for="modalRecargo">% Recargo</label>
                  <input v-model.number="form.porc_recargo" type="number" min="0" step="0.01" class="form-control" id="modalRecargo" required />
                </div>
                <div class="col">
                  <label for="modalMulta">% Multa</label>
                  <input v-model.number="form.porc_multa" type="number" min="0" step="0.01" class="form-control" id="modalMulta" required />
                </div>
              </div>
              <div v-if="formError" class="alert alert-danger mt-2">{{ formError }}</div>
            </div>
            <div class="modal-footer">
              <button type="submit" class="btn btn-primary">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <div v-if="apiMessage" class="alert" :class="{'alert-success': apiSuccess, 'alert-danger': !apiSuccess}">{{ apiMessage }}</div>
  </div>
</template>

<script>
export default {
  name: 'RecargosPage',
  data() {
    return {
      searchYear: new Date().getFullYear(),
      recargos: [],
      showCreate: false,
      editItem: null,
      form: {
        year: '',
        month: '',
        porc_recargo: '',
        porc_multa: ''
      },
      formError: '',
      apiMessage: '',
      apiSuccess: true
    };
  },
  methods: {
    fetchRecargos() {
      this.apiMessage = '';
      this.recargos = [];
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'recargos.list',
          params: { year: this.searchYear }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) {
            this.recargos = (json.data || []).map(r => ({
              ano_mes: r.ano_mes || r.ano_mes_recargo || r.aso_mes_recargo,
              year: r.ano || r.year || r.ano_mes_recargo?.split('-')[0],
              mes: r.mes || r.month || (r.ano_mes_recargo?.split('-')[1] || r.aso_mes_recargo?.split('-')[1]),
              porc_recargo: r.porc_recargo,
              porc_multa: r.porc_multa
            }));
          } else {
            this.apiMessage = json.message || 'Error al consultar recargos';
            this.apiSuccess = false;
          }
        })
        .catch(e => {
          this.apiMessage = e.message;
          this.apiSuccess = false;
        });
    },
    editRecargo(item) {
      this.editItem = item;
      this.form = {
        year: parseInt(item.year),
        month: parseInt(item.mes),
        porc_recargo: item.porc_recargo,
        porc_multa: item.porc_multa
      };
      this.formError = '';
      this.showCreate = false;
    },
    deleteRecargo(item) {
      if (!confirm('¿Está seguro de eliminar el recargo del mes ' + item.mes + '?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'recargos.delete',
          params: { year: parseInt(item.year), month: parseInt(item.mes) }
        })
      })
        .then(res => res.json())
        .then(json => {
          this.apiMessage = json.message;
          this.apiSuccess = json.success;
          if (json.success) this.fetchRecargos();
        });
    },
    saveRecargo() {
      this.formError = '';
      if (!this.form.year || !this.form.month || this.form.porc_recargo === '' || this.form.porc_multa === '') {
        this.formError = 'Todos los campos son obligatorios';
        return;
      }
      const action = this.editItem ? 'recargos.update' : 'recargos.create';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action,
          params: {
            year: parseInt(this.form.year),
            month: parseInt(this.form.month),
            porc_recargo: parseFloat(this.form.porc_recargo),
            porc_multa: parseFloat(this.form.porc_multa)
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          this.apiMessage = json.message;
          this.apiSuccess = json.success;
          if (json.success) {
            this.closeModal();
            this.fetchRecargos();
          }
        });
    },
    closeModal() {
      this.showCreate = false;
      this.editItem = null;
      this.form = { year: '', month: '', porc_recargo: '', porc_multa: '' };
      this.formError = '';
    }
  },
  mounted() {
    this.fetchRecargos();
  }
};
</script>

<style scoped>
.recargos-page {
  max-width: 800px;
  margin: 0 auto;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-dialog {
  background: #fff;
  border-radius: 6px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
  min-width: 400px;
  max-width: 90vw;
}
</style>
