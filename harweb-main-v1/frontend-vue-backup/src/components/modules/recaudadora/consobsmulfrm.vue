<template>
  <div class="consobsmulfrm-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Observaciones de Multa</span>
    </nav>
    <h1>Observaciones asociadas a la multa</h1>
    <form @submit.prevent="onSearch">
      <label for="criterio">Buscar por:</label>
      <select v-model="search.criterio" id="criterio">
        <option value="contribuyente">Contribuyente</option>
        <option value="domicilio">Domicilio</option>
        <option value="num_acta">Número de Acta</option>
        <option value="axo_acta">Año de Acta</option>
      </select>
      <input v-model="search.valor" placeholder="Valor a buscar" />
      <button type="submit">Buscar</button>
    </form>
    <div v-if="multas.length">
      <h2>Resultados</h2>
      <table class="multas-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Contribuyente</th>
            <th>Domicilio</th>
            <th>Año</th>
            <th>Acta</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="m in multas" :key="m.id_multa">
            <td>{{ m.id_multa }}</td>
            <td>{{ m.contribuyente }}</td>
            <td>{{ m.domicilio }}</td>
            <td>{{ m.axo_acta }}</td>
            <td>{{ m.num_acta }}</td>
            <td>
              <button @click="selectMulta(m)">Ver/Editar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="selected">
      <h2>Editar Observaciones</h2>
      <form @submit.prevent="onSave">
        <div>
          <label>Observación del acta de infracción</label>
          <textarea v-model="selected.observacion" rows="4" style="width:100%"></textarea>
        </div>
        <div>
          <label>Comentario</label>
          <input v-model="selected.comentario" type="text" style="width:100%" />
        </div>
        <button type="submit">Guardar</button>
        <button type="button" @click="selected=null">Cancelar</button>
      </form>
    </div>
    <div v-if="message" class="message">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsObsMulFrm',
  data() {
    return {
      search: {
        criterio: 'contribuyente',
        valor: ''
      },
      multas: [],
      selected: null,
      message: ''
    }
  },
  methods: {
    async onSearch() {
      this.message = '';
      this.selected = null;
      this.multas = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'search_multas',
            params: this.search
          })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.multas = data.data;
          if (!this.multas.length) this.message = 'No se encontraron resultados.';
        } else {
          this.message = data.message;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor.';
      }
    },
    async selectMulta(m) {
      this.message = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_observaciones',
            params: { id_multa: m.id_multa }
          })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.selected = { ...data.data };
        } else {
          this.message = data.message;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor.';
      }
    },
    async onSave() {
      this.message = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'update_observaciones',
            params: {
              id_multa: this.selected.id_multa,
              observacion: this.selected.observacion,
              comentario: this.selected.comentario
            }
          })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.message = 'Observaciones guardadas correctamente.';
          this.selected = null;
          this.onSearch();
        } else {
          this.message = data.message;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor.';
      }
    }
  }
}
</script>

<style scoped>
.consobsmulfrm-page {
  max-width: 800px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
  color: #888;
}
.multas-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.multas-table th, .multas-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.multas-table th {
  background: #f8f8f8;
}
.message {
  margin-top: 1rem;
  color: #b00;
}
</style>
